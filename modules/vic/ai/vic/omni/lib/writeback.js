// writeback.js — safety-critical persistence of agent-distilled lessons into
// Vic's ~/.claude. Zero external deps; node builtins only. Fail-closed: the
// FIRST gate failure returns {ok:false,gate,reason} and writes NOTHING.
//
// The threat model is "do not corrupt Vic's hand-written config". Defenses:
//   * entries live ONLY inside a segregated machine region (two HTML markers);
//   * the human zone (everything outside the markers) is byte-hash pinned;
//   * frontmatter is emitted once, never edited, and round-trip verified;
//   * every edit offset is clamped inside the region or the write aborts;
//   * realpath/symlink escape out of `root` aborts;
//   * writes are atomic (tmp + fsync + rename + dir fsync) under an advisory lock.

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import os from 'node:os';
import { execFileSync } from 'node:child_process';

const REGION_HEADER = '## Auto-learned (omni)';
const START = '<!-- omni:region-start -->';
const END = '<!-- omni:region-end -->';
const TMP_SUFFIX = '.omni.tmp';
const LOCK_TTL_MS = 30_000;
const MAX_ENTRIES = 64;
const MAX_BYTES = 64 * 1024;

const sha = (s) => crypto.createHash('sha256').update(s).digest('hex');
const reject = (gate, reason) => ({ ok: false, gate, reason });

// ── volatile-token normalization for the dedup key ─────────────────────────
function normalize(s) {
  let out = String(s).toLowerCase();
  out = out
    .replace(/\b[0-9a-f]{7,}\b/g, '·') // hex blobs ≥7 chars
    .replace(/\b\d{4}-\d{2}-\d{2}t[\d:.]+z?\b/g, '·') // ISO timestamps
    .replace(/\b\d{10,}\b/g, '·') // epoch
    .replace(/(?:\/tmp|\/var\/folders)\/\S+/g, '·') // tmp paths
    .replace(/\/[^\s:]+/g, '·') // absolute paths
    .replace(/:\d+/g, '·') // :linenums
    .replace(/\s+/g, ' ')
    .trim();
  return out;
}

function dedupKey(lesson) {
  const basis = `${lesson.scope}\x1f${lesson.type}\x1f${normalize(lesson.signature)}`;
  return sha(basis).slice(0, 12);
}

function mapMetaType(t) {
  const feedback = new Set(['gotcha', 'pitfall', 'correction', 'feedback', 'antipattern']);
  const project = new Set(['decision', 'config', 'project', 'convention']);
  if (feedback.has(t)) return 'feedback';
  if (project.has(t)) return 'project';
  return 'reference';
}

function computeTier(evidence) {
  const ev = evidence || {};
  const occ = ev.occurrences | 0;
  const sessions = (ev.sessions || []).length;
  const projects = (ev.projects || []).length;
  const t1 = occ >= 3 && sessions >= 2;
  const t2 = occ >= 5 && projects >= 2;
  return { t1, t2 };
}

const tierRank = { T1: 1, T2: 2 };

// ── path resolution: returns realpath of the deepest existing ancestor ─────
function deepestRealParent(p) {
  let cur = p;
  for (;;) {
    if (fs.existsSync(cur)) return fs.realpathSync(cur);
    const up = path.dirname(cur);
    if (up === cur) return fs.realpathSync(up);
    cur = up;
  }
}

// realpath(root) must be a strict path-prefix of `target` (component-wise).
function underRoot(rootReal, target) {
  const rel = path.relative(rootReal, target);
  return rel !== '' && !rel.startsWith('..') && !path.isAbsolute(rel);
}

// ── canonical frontmatter (the ONLY YAML omni emits — narrow on purpose) ───
// Parses the constrained shape {name, description, metadata:{...}} and re-emits
// it byte-canonically. If the on-disk frontmatter does not round-trip exactly,
// guard() treats it as mutated/foreign and refuses to touch the file.
function parseFrontmatter(fmText) {
  const lines = fmText.split('\n');
  if (lines[0] !== '---') return null;
  let i = 1;
  const data = {};
  for (; i < lines.length; i++) {
    const ln = lines[i];
    if (ln === '---') return { data, ok: true };
    const top = /^([A-Za-z_][\w-]*):(?: (.*))?$/.exec(ln);
    if (!top) return null;
    const key = top[1];
    const val = top[2];
    if (val === undefined || val === '') {
      // nested block (e.g. metadata:) — collect "  k: v" lines
      const nested = {};
      while (i + 1 < lines.length && /^ {2}\S/.test(lines[i + 1])) {
        i++;
        const sub = /^ {2}([A-Za-z_][\w-]*): (.*)$/.exec(lines[i]);
        if (!sub) return null;
        nested[sub[1]] = sub[2];
      }
      data[key] = nested;
    } else {
      data[key] = val;
    }
  }
  return null; // unterminated
}

function emitFrontmatter(data) {
  let out = '---\n';
  for (const [k, v] of Object.entries(data)) {
    if (v && typeof v === 'object') {
      out += `${k}:\n`;
      for (const [sk, sv] of Object.entries(v)) out += `  ${sk}: ${sv}\n`;
    } else {
      out += `${k}: ${v}\n`;
    }
  }
  out += '---\n';
  return out;
}

// ── frontmatter / human-zone guard ─────────────────────────────────────────
// raw      : current on-disk bytes (utf8 string)
// rendered : proposed full bytes (utf8 string)
// offsets  : [editStart, editEnd] byte offsets of the mutated span in `raw`
function guard(raw, rendered, offsets) {
  if (!raw.startsWith('---\n')) return reject('corrupt', 'no-frontmatter');
  const close = raw.indexOf('\n---', 4);
  if (close < 0) return reject('corrupt', 'unterminated');
  const fmEnd = close + '\n---\n'.length; // first body byte
  const fmText = raw.slice(0, fmEnd).replace(/\n$/, '');

  const parsed = parseFrontmatter(fmText);
  if (!parsed) return reject('frontmatter', 'unparseable');
  if (emitFrontmatter(parsed.data) !== raw.slice(0, fmEnd)) {
    return reject('frontmatter', 'mutated');
  }

  const rs = raw.indexOf(START);
  const re = raw.indexOf(END);
  if (rs < 0 || re < 0 || re < rs) return reject('corrupt', 'markers');
  const regionOpen = rs + (START + '\n').length;
  const regionClose = re;

  for (const off of offsets) {
    if (off < fmEnd) return reject('frontmatter', 'write-into-frontmatter');
    if (off < regionOpen || off > regionClose) {
      return reject('frontmatter', 'outside-region');
    }
  }

  // post-render byte-hash pinning of the human zone (prefix + suffix)
  if (sha(rendered.slice(0, regionOpen)) !== sha(raw.slice(0, regionOpen))) {
    return reject('frontmatter', 'prefix-drift');
  }
  const rClose = rendered.indexOf(END);
  if (rClose < 0) return reject('corrupt', 'markers');
  if (sha(rendered.slice(rClose)) !== sha(raw.slice(regionClose))) {
    return reject('human-zone', 'suffix-drift');
  }
  return { ok: true };
}

// ── region rendering ───────────────────────────────────────────────────────
function entryBlock(lesson, dedup, ts, occ, srcLine) {
  const related = lesson.related ? ` [[${lesson.related}]]` : '';
  const conf = lesson.confidence;
  const src = `${(lesson.evidence?.sessions || ['?'])[0]}:${srcLine}`;
  const sig = String(lesson.signature || '').replace(/\r?\n/g, ' ');
  const res = String(lesson.resolution || '').replace(/\r?\n/g, ' ');
  return (
    `<!-- omni:auto id=${dedup} conf=${conf} src=${src} ts=${ts} occ=${occ} -->\n` +
    `- **${sig}** — ${res}${related}`
  );
}

function freshRegion(lesson, dedup, ts) {
  const entry = entryBlock(lesson, dedup, ts, 1, 1);
  return `${REGION_HEADER}\n${START}\n${entry}\n${END}\n`;
}

function freshFile(lesson, dedup, ts, slug) {
  const desc = String(lesson.resolution || lesson.signature || '').replace(/\r?\n/g, ' ');
  const fm = emitFrontmatter({
    name: slug,
    description: desc,
    metadata: { node_type: 'memory', type: mapMetaType(lesson.type) },
  });
  return `${fm}\n${freshRegion(lesson, dedup, ts)}`;
}

// Insert a brand-new entry immediately before END; returns {text,offsets}.
function appendEntry(raw, lesson, dedup, ts) {
  const re = raw.indexOf(END);
  const newEntry = `${entryBlock(lesson, dedup, ts, 1, 1)}\n`;
  const text = raw.slice(0, re) + newEntry + raw.slice(re);
  return { text, offsets: [re, re + newEntry.length] };
}

// Rewrite ONLY the entry whose marker carries id=<dedup>; bump occ.
function updateEntry(raw, lesson, dedup, ts) {
  const marker = `<!-- omni:auto id=${dedup} `;
  const mStart = raw.indexOf(marker);
  if (mStart < 0) return null;
  // entry = marker comment line + the following bullet line
  const lineEnd = raw.indexOf('\n', mStart);
  const bulletEnd = raw.indexOf('\n', lineEnd + 1);
  const entryEnd = bulletEnd < 0 ? raw.length : bulletEnd;
  const oldOcc = /occ=(\d+)/.exec(raw.slice(mStart, lineEnd));
  const occ = (oldOcc ? parseInt(oldOcc[1], 10) : 1) + 1;
  const replacement = entryBlock(lesson, dedup, ts, occ, 1);
  const text = raw.slice(0, mStart) + replacement + raw.slice(entryEnd);
  return { text, offsets: [mStart, mStart + replacement.length] };
}

function countEntries(text) {
  return (text.match(/<!-- omni:auto id=/g) || []).length;
}

function unifiedDiff(before, after, file) {
  const a = before.split('\n');
  const b = after.split('\n');
  const out = [`--- ${file} (current)`, `+++ ${file} (proposed)`];
  // coarse line diff: shared prefix/suffix, middle shown as -/+ (good enough
  // for human review; this module's contract is the gates, not diff fidelity).
  let p = 0;
  while (p < a.length && p < b.length && a[p] === b[p]) p++;
  let sa = a.length - 1;
  let sb = b.length - 1;
  while (sa >= p && sb >= p && a[sa] === b[sb]) { sa--; sb--; }
  out.push(`@@ -${p + 1},${sa - p + 1} +${p + 1},${sb - p + 1} @@`);
  for (let i = p; i <= sa; i++) out.push(`-${a[i]}`);
  for (let i = p; i <= sb; i++) out.push(`+${b[i]}`);
  return out.join('\n');
}

// ── MEMORY.md index line (dedup by '(<slug>.md)' substring) ────────────────
function ensureIndexLine(memDir, slug, hook) {
  const idx = path.join(memDir, 'MEMORY.md');
  const needle = `(${slug}.md)`;
  let body = fs.existsSync(idx) ? fs.readFileSync(idx, 'utf8') : '# Memory Index\n';
  if (body.includes(needle)) return;
  const title = slug;
  const line = `- [${title}](${slug}.md) — ${hook}\n`;
  if (!body.endsWith('\n')) body += '\n';
  body += line;
  atomicWrite(idx, body);
}

// ── advisory lock (O_CREAT|O_EXCL, break if stale) ─────────────────────────
function acquireLock(lockPath) {
  fs.mkdirSync(path.dirname(lockPath), { recursive: true });
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const fd = fs.openSync(lockPath, 'wx');
      fs.writeSync(fd, `${process.pid}\n${Date.now()}\n`);
      fs.closeSync(fd);
      return true;
    } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      let stale = true;
      try {
        const cur = fs.readFileSync(lockPath, 'utf8').split('\n');
        const ts = parseInt(cur[1], 10);
        stale = !Number.isFinite(ts) || Date.now() - ts > LOCK_TTL_MS;
      } catch { stale = true; }
      if (!stale) return false;
      try { fs.rmSync(lockPath, { force: true }); } catch { /* retry */ }
    }
  }
  return false;
}
function releaseLock(lockPath) {
  try { fs.rmSync(lockPath, { force: true }); } catch { /* best effort */ }
}

// ── atomic write: tmp + fsync(fd) + rename + fsync(dir) ────────────────────
function atomicWrite(file, bytes) {
  const dir = path.dirname(file);
  fs.mkdirSync(dir, { recursive: true });
  const tmp = file + TMP_SUFFIX;
  const fd = fs.openSync(tmp, 'w');
  try {
    fs.writeSync(fd, bytes);
    fs.fsyncSync(fd);
  } finally {
    fs.closeSync(fd);
  }
  fs.renameSync(tmp, file);
  let dfd;
  try {
    dfd = fs.openSync(dir, 'r');
    fs.fsyncSync(dfd);
  } catch { /* dir fsync unsupported on some FS — non-fatal */ } finally {
    if (dfd !== undefined) try { fs.closeSync(dfd); } catch { /* ignore */ }
  }
}

// ── memory dir: settings.json autoMemoryDirectory (abs or ~/), else per-project ──
// Claude Code reads memories from there; writing elsewhere = lessons never recalled.
function memoryDir(root, slug) {
  let auto;
  try { auto = JSON.parse(fs.readFileSync(path.join(root, 'settings.json'), 'utf8')).autoMemoryDirectory; } catch { /* no settings */ }
  if (typeof auto !== 'string' || auto === '') return path.join(root, 'projects', slug, 'memory');
  return auto.startsWith('~/') ? path.join(os.homedir(), auto.slice(2)) : path.resolve(root, auto);
}

// ── resolve target → { dir, file, slug, name, tier } ───────────────────────
function resolveTarget(root, target) {
  if (target.kind === 'memory') {
    const slug = target.slug;
    const dir = memoryDir(root, slug);
    return { dir, file: path.join(dir, `${slug}.md`), slug, tier: 'T1' };
  }
  if (target.kind === 'skill') {
    const name = target.name;
    const dir = path.join(root, 'skills', name || '');
    return { dir, file: path.join(dir, 'SKILL.md'), slug: name, name, tier: 'T2' };
  }
  return null;
}

// ───────────────────────────────────────────────────────────────────────────
export function writeLesson({ root, target, lesson, mode } = {}) {
  root = root || path.join(os.homedir(), '.claude');
  const live = mode ? mode === 'live' : process.env.OMNI_WRITE === 'live';
  const ts = new Date().toISOString();
  const dedup = lesson ? dedupKey(lesson) : undefined;

  const tgt = resolveTarget(root, target || {});
  if (!tgt) return reject('scope', 'unknown-target');
  const wantTier = tgt.tier;

  let rootReal;
  try { rootReal = fs.realpathSync(root); } catch { return reject('scope', 'root-missing'); }

  // GATE 1 — scope-assert
  if (!lesson || lesson.scope == null || lesson.scope === '') return reject('scope', 'no-scope');
  if ((target.kind === 'skill' || lesson.scope === 'GLOBAL') && !tgt.name) {
    return reject('scope', 'name-required');
  }
  const dirReal = (() => {
    try { return deepestRealParent(tgt.dir); } catch { return null; }
  })();
  if (!dirReal) return reject('scope', 'no-parent');

  // GATE 2 — symlink-escape: every realpath'd component stays under root
  const fileParentReal = deepestRealParent(tgt.file);
  if (!underRoot(rootReal, fileParentReal) && fileParentReal !== rootReal) {
    return reject('escape', 'parent-outside-root');
  }
  if (!underRoot(rootReal, dirReal) && dirReal !== rootReal) {
    return reject('escape', 'dir-outside-root');
  }
  if (fs.existsSync(tgt.file)) {
    const fReal = fs.realpathSync(tgt.file);
    if (!underRoot(rootReal, fReal)) return reject('escape', 'file-outside-root');
  }

  // GATE 3 — self-write loop guard
  for (const ln of [lesson.signature, lesson.resolution, lesson.trigger]) {
    if (typeof ln === 'string' && ln.includes('omni:auto')) return reject('loop', 'self-marker');
  }

  // GATE 4 — promotion-gate
  const tier = computeTier(lesson.evidence);
  const computedRank = tier.t2 ? 2 : tier.t1 ? 1 : 0;
  if (tierRank[wantTier] > computedRank) return reject('under-evidenced', `need-${wantTier}`);
  if (wantTier === 'T2' && !tgt.name) return reject('under-evidenced', 'skill-needs-name');

  const exists = fs.existsSync(tgt.file);
  const raw = exists ? fs.readFileSync(tgt.file, 'utf8') : null;

  // Build proposed bytes + edit offsets.
  let proposed;
  let offsets;
  let kind; // 'new' | 'append' | 'update'
  if (!exists) {
    proposed = freshFile(lesson, dedup, ts, tgt.slug);
    kind = 'new';
    // new file: whole file is the "edit"; human-zone pins are trivially equal
    offsets = null;
  } else {
    const upd = updateEntry(raw, lesson, dedup, ts);
    if (upd) { proposed = upd.text; offsets = upd.offsets; kind = 'update'; }
    else {
      const app = appendEntry(raw, lesson, dedup, ts);
      proposed = app.text; offsets = app.offsets; kind = 'append';
    }
  }

  // GATE 5 + 6 — frontmatter-guard & region-integrity (only meaningful when
  // editing an existing managed file; a fresh file is emitted whole by us).
  if (exists) {
    const g = guard(raw, proposed, offsets);
    if (!g.ok) return g;
  } else {
    // region-integrity on what we will emit
    if (proposed.indexOf(START) < 0 || proposed.indexOf(END) < 0) {
      return reject('corrupt', 'markers');
    }
    const fmEnd = proposed.indexOf('\n---\n', 4) + 5;
    const p = parseFrontmatter(proposed.slice(0, fmEnd).replace(/\n$/, ''));
    if (!p || emitFrontmatter(p.data) !== proposed.slice(0, fmEnd)) {
      return reject('corrupt', 'frontmatter-roundtrip');
    }
  }

  // GATE 7 — cap (skip when idempotent in-place update has no net growth)
  const netGrows = !exists || kind === 'append' || proposed.length > (raw ? raw.length : 0);
  if (netGrows) {
    if (countEntries(proposed) > MAX_ENTRIES) return reject('cap', 'too-many-entries');
    if (Buffer.byteLength(proposed) > MAX_BYTES) return reject('cap', 'too-many-bytes');
  }

  // GATE 8 — render+validate (markers paired; edit span inside region)
  {
    const rs = proposed.indexOf(START);
    const re = proposed.indexOf(END);
    if (rs < 0 || re < 0 || re < rs) return reject('render', 'markers');
    if (offsets) {
      const open = rs + (START + '\n').length;
      if (offsets[0] < open || offsets[1] > re + (END.length)) {
        return reject('render', 'edit-span-outside-region');
      }
    }
  }

  const diff = unifiedDiff(raw || '', proposed, tgt.file);

  // DRY-RUN stops here — nothing written.
  if (!live) {
    return { ok: true, dryRun: true, tier: wantTier, dedup, diff };
  }

  // ── MUTATE (live only) ───────────────────────────────────────────────────
  const omniDir = path.join(root, '.omni');
  const lockPath = path.join(omniDir, 'lock');
  if (!acquireLock(lockPath)) return reject('lock', 'busy');
  try {
    // GATE 9 — snapshot (best-effort jj) + mandatory .bak + revert.log
    try {
      execFileSync('jj', ['file', 'track', tgt.file], { cwd: root, stdio: 'ignore', timeout: 2000 });
    } catch { /* sandbox / non-jj — must NOT throw */ }

    const baksDir = path.join(omniDir, 'baks');
    fs.mkdirSync(baksDir, { recursive: true });
    const bak = path.join(baksDir, `${tgt.slug}.${ts.replace(/[:.]/g, '-')}.${dedup}.bak`);
    const id = `${dedup}.${Date.now()}`;
    atomicWrite(bak, exists ? raw : ''); // empty bak ⇒ revert deletes a created file
    fs.appendFileSync(
      path.join(omniDir, 'revert.log'),
      JSON.stringify({ id, dedup, path: tgt.file, bak, ts, existed: exists }) + '\n',
    );

    // GATE 10 — atomic write
    atomicWrite(tgt.file, proposed);

    // memory new-file: also append MEMORY.md index line
    if (kind === 'new' && target.kind === 'memory') {
      const hook = (lesson.resolution || lesson.signature).split('\n')[0].slice(0, 120);
      ensureIndexLine(tgt.dir, tgt.slug, hook);
    }

    // GATE 11
    return { ok: true, tier: wantTier, dedup, path: tgt.file, revertId: id };
  } finally {
    releaseLock(lockPath);
  }
}

// ───────────────────────────────────────────────────────────────────────────
export function revert({ root, id } = {}) {
  root = root || path.join(os.homedir(), '.claude');
  const logPath = path.join(root, '.omni', 'revert.log');
  if (!fs.existsSync(logPath)) return { ok: false, path: null };
  const lines = fs.readFileSync(logPath, 'utf8').split('\n').filter(Boolean);
  let rec = null;
  for (let i = lines.length - 1; i >= 0; i--) {
    try {
      const obj = JSON.parse(lines[i]);
      if (obj.id === id) { rec = obj; break; }
    } catch { /* skip malformed */ }
  }
  if (!rec) return { ok: false, path: null };
  if (rec.existed) {
    const bakBytes = fs.readFileSync(rec.bak, 'utf8');
    atomicWrite(rec.path, bakBytes);
  } else {
    // file was created by the write → revert removes it
    try { fs.rmSync(rec.path, { force: true }); } catch { /* already gone */ }
  }
  return { ok: true, path: rec.path };
}

export const _internal = { normalize, dedupKey, computeTier, guard, parseFrontmatter, emitFrontmatter };
