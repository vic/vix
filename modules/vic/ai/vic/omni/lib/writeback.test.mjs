// Oracle self-test for lib/writeback.js — node:assert + mktemp sandbox.
// NEVER touches the real ~/.claude. Run: timeout 5 node lib/writeback.test.mjs
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { writeLesson, revert } from './writeback.js';

let PASS = 0;
function ok(name) { PASS++; console.log(`ok ${PASS} - ${name}`); }

function mkroot() {
  return fs.mkdtempSync(path.join(os.tmpdir(), 'omni-wb-'));
}

const baseLesson = (over = {}) => ({
  type: 'gotcha',
  signature: 'fsync before rename for atomic write at /abs/path/x.js:42 deadbeef123',
  trigger: 'partial write observed',
  resolution: 'fsync fd then renameSync then fsync dir',
  scope: 'omni',
  confidence: 0.9,
  related: 'atomic-io',
  evidence: { sessions: ['s1', 's2', 's3'], projects: ['omni'], occurrences: 4, models: ['opus'] },
  ...over,
});

// ── A. dry-run on new memory target: {ok,dryRun,diff}, writes NO file ──────
function caseA() {
  const root = mkroot();
  const target = { kind: 'memory', slug: 'omni-atomic' };
  const r = writeLesson({ root, target, lesson: baseLesson(), mode: 'dry' });
  assert.equal(r.ok, true, 'A: ok');
  assert.equal(r.dryRun, true, 'A: dryRun');
  assert.equal(typeof r.diff, 'string', 'A: diff is string');
  assert.ok(r.diff.length > 0, 'A: diff non-empty');
  assert.equal(r.tier, 'T1', 'A: tier T1');
  const file = path.join(root, 'projects', 'omni-atomic', 'memory', 'omni-atomic.md');
  assert.equal(fs.existsSync(file), false, 'A: file NOT created by dry-run');
  ok('A dry-run returns diff, writes nothing');
}

// ── B. live write creates valid file; re-run is idempotent (occ bump) ──────
function caseB() {
  const root = mkroot();
  const target = { kind: 'memory', slug: 'omni-atomic' };
  const file = path.join(root, 'projects', 'omni-atomic', 'memory', 'omni-atomic.md');

  const r1 = writeLesson({ root, target, lesson: baseLesson(), mode: 'live' });
  assert.equal(r1.ok, true, 'B: first write ok');
  assert.equal(fs.existsSync(file), true, 'B: file created');
  const txt1 = fs.readFileSync(file, 'utf8');
  assert.ok(txt1.startsWith('---\n'), 'B: has frontmatter');
  assert.ok(txt1.includes('<!-- omni:region-start -->'), 'B: region-start present');
  assert.ok(txt1.includes('<!-- omni:region-end -->'), 'B: region-end present');
  // exactly one entry marker
  const occ1 = (txt1.match(/omni:auto id=/g) || []).length;
  assert.equal(occ1, 1, 'B: exactly one entry after first write');
  // MEMORY.md index line appended
  const mem = fs.readFileSync(path.join(root, 'projects', 'omni-atomic', 'memory', 'MEMORY.md'), 'utf8');
  assert.ok(mem.includes('(omni-atomic.md)'), 'B: MEMORY.md index line');

  // idempotent re-run: same dedup, occ bumps, NO second entry
  const r2 = writeLesson({ root, target, lesson: baseLesson(), mode: 'live' });
  assert.equal(r2.ok, true, 'B: second write ok');
  assert.equal(r2.dedup, r1.dedup, 'B: same dedup key');
  const txt2 = fs.readFileSync(file, 'utf8');
  const occ2 = (txt2.match(/omni:auto id=/g) || []).length;
  assert.equal(occ2, 1, 'B: STILL one entry (idempotent, no dup)');
  assert.ok(/occ=2\b/.test(txt2), 'B: occurrence counter bumped to 2');
  ok('B live write + idempotent update');
}

// ── C. FRONTMATTER ATTACK: offsets land in frontmatter/description → reject ─
function caseC() {
  const root = mkroot();
  const target = { kind: 'memory', slug: 'omni-atk' };
  // create a valid managed file first
  const r1 = writeLesson({ root, target, lesson: baseLesson(), mode: 'live' });
  assert.equal(r1.ok, true, 'C: setup write ok');
  const file = path.join(root, 'projects', 'omni-atk', 'memory', 'omni-atk.md');

  // Tamper: move the region markers INTO the frontmatter so any edit offset
  // computed for the region necessarily lands within [0,fmEnd) / on description.
  // We corrupt the on-disk file, then attempt an append (new dedup) — the
  // frontmatter-guard must reject because edit offsets fall before fmEnd.
  const good = fs.readFileSync(file, 'utf8');
  const fmClose = good.indexOf('\n---\n', 4) + 5;
  // splice region markers up into the description line region (before fmEnd)
  const tampered =
    good.slice(0, 4) +
    'name: omni-atk\n' +
    '<!-- omni:region-start -->\n<!-- omni:region-end -->\n' +  // markers INSIDE frontmatter
    'description: x\n' +
    good.slice(good.indexOf('---\n', 4));
  void fmClose;
  fs.writeFileSync(file, tampered);

  const r2 = writeLesson({
    root, target,
    lesson: baseLesson({ signature: 'totally different sig zzz', type: 'perf' }),
    mode: 'live',
  });
  assert.equal(r2.ok, false, 'C: attack write rejected');
  assert.ok(String(r2.gate).startsWith('frontmatter') || String(r2.gate) === 'corrupt',
    `C: gate is frontmatter/corrupt (got ${r2.gate}:${r2.reason})`);
  ok('C frontmatter attack REJECTED');
}

// ── D. symlink-escape: realpath leaves sandbox → {ok:false, gate:'escape'} ──
function caseD() {
  const root = mkroot();
  const outside = mkroot(); // a sibling temp dir OUTSIDE root
  const slug = 'omni-esc';
  // Pre-build the memory dir as a symlink pointing outside root.
  const projMem = path.join(root, 'projects', slug, 'memory');
  fs.mkdirSync(path.dirname(projMem), { recursive: true });
  fs.symlinkSync(outside, projMem, 'dir');

  const r = writeLesson({ root, target: { kind: 'memory', slug }, lesson: baseLesson(), mode: 'live' });
  assert.equal(r.ok, false, 'D: escape write rejected');
  assert.equal(r.gate, 'escape', `D: gate=escape (got ${r.gate}:${r.reason})`);
  // and nothing was written into the outside dir
  const leaked = path.join(outside, `${slug}.md`);
  assert.equal(fs.existsSync(leaked), false, 'D: no file leaked outside root');
  ok('D symlink-escape REJECTED');
}

// ── E. atomicity: no leftover *.omni.tmp; file parses; revert works ─────────
function caseE() {
  const root = mkroot();
  const target = { kind: 'memory', slug: 'omni-atom2' };
  const r = writeLesson({ root, target, lesson: baseLesson(), mode: 'live' });
  assert.equal(r.ok, true, 'E: write ok');
  const dir = path.join(root, 'projects', 'omni-atom2', 'memory');
  const leftovers = fs.readdirSync(dir).filter((f) => f.endsWith('.omni.tmp'));
  assert.equal(leftovers.length, 0, 'E: no *.omni.tmp leftovers');
  const file = path.join(dir, 'omni-atom2.md');
  const txt = fs.readFileSync(file, 'utf8');
  assert.ok(txt.startsWith('---\n') && txt.includes('\n---\n'), 'E: parseable frontmatter');
  // revert restores baseline (pre-write file was absent → revert leaves a baseline copy)
  assert.ok(r.revertId, 'E: revertId present');
  const rv = revert({ root, id: r.revertId });
  assert.equal(rv.ok, true, 'E: revert ok');
  ok('E atomicity + revert');
}

// ── F. FIX-5: multi-line resolution must not corrupt the entry block ─────────
function caseF() {
  const root = mkroot();
  const target = { kind: 'memory', slug: 'omni-multiline' };
  const mlLesson = () => baseLesson({
    signature: 'multiline\nsignature here',
    resolution: 'step one\nstep two\nstep three',
  });

  // First write
  const r1 = writeLesson({ root, target, lesson: mlLesson(), mode: 'live' });
  assert.equal(r1.ok, true, 'F: first multiline write ok');
  const file = path.join(root, 'projects', 'omni-multiline', 'memory', 'omni-multiline.md');
  const txt1 = fs.readFileSync(file, 'utf8');
  // The bullet line must be exactly one line (no embedded newlines)
  const bulletMatch = /^- \*\*.*\*\* — .*$/m.exec(txt1);
  assert.ok(bulletMatch, 'F: entry bullet is a single line');
  assert.ok(!bulletMatch[0].includes('\n'), 'F: no embedded newline in bullet');

  // Second write (update same dedup) — file must still parse correctly
  const r2 = writeLesson({ root, target, lesson: mlLesson(), mode: 'live' });
  assert.equal(r2.ok, true, 'F: second multiline write ok (update)');
  const txt2 = fs.readFileSync(file, 'utf8');
  assert.ok(txt2.startsWith('---\n'), 'F: file still has frontmatter after update');
  assert.ok(txt2.includes('<!-- omni:region-start -->'), 'F: region-start still present');
  // Still exactly one entry
  const entryCount = (txt2.match(/<!-- omni:auto id=/g) || []).length;
  assert.equal(entryCount, 1, 'F: still exactly one entry after multiline update');
  // occ bumped
  assert.ok(/occ=2\b/.test(txt2), 'F: occ bumped to 2 after update');
  ok('F multiline resolution sanitized — entry intact after update');
}

// ── G. settings.json autoMemoryDirectory (abs + ~/) wins over projects/<slug>/memory ──
function caseG() {
  const abs = mkroot();
  fs.writeFileSync(path.join(abs, 'settings.json'), JSON.stringify({ autoMemoryDirectory: path.join(abs, 'memory') }));
  const r1 = writeLesson({ root: abs, target: { kind: 'memory', slug: 'omni-amd' }, lesson: baseLesson(), mode: 'live' });
  assert.equal(r1.ok, true, `G: abs write ok (got ${r1.gate}:${r1.reason})`);
  assert.equal(fs.existsSync(path.join(abs, 'memory', 'omni-amd.md')), true, 'G: abs file in autoMemoryDirectory');
  assert.equal(fs.existsSync(path.join(abs, 'memory', 'MEMORY.md')), true, 'G: abs MEMORY.md in autoMemoryDirectory');
  assert.equal(fs.existsSync(path.join(abs, 'projects')), false, 'G: abs nothing under projects/');

  const home = mkroot();
  const root = path.join(home, '.claude');
  fs.mkdirSync(root);
  fs.writeFileSync(path.join(root, 'settings.json'), JSON.stringify({ autoMemoryDirectory: '~/.claude/memory' }));
  const prev = process.env.HOME;
  process.env.HOME = home;
  try {
    const r2 = writeLesson({ root, target: { kind: 'memory', slug: 'omni-amd' }, lesson: baseLesson(), mode: 'live' });
    assert.equal(r2.ok, true, `G: tilde write ok (got ${r2.gate}:${r2.reason})`);
  } finally { process.env.HOME = prev; }
  assert.equal(fs.existsSync(path.join(root, 'memory', 'omni-amd.md')), true, 'G: ~/ expanded to HOME');
  ok('G autoMemoryDirectory honored (abs + ~/)');
}

caseA();
caseB();
caseC();
caseD();
caseE();
caseF();
caseG();
console.log(`\n# ${PASS} cases passed`);
