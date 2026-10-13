// ingest.js — walk ~/.claude/projects RECURSIVELY (top-level sessions +
// <uuid>/subagents/agent-*.jsonl). Build structural graph. Append-only
// incremental: only NEW lines processed (idempotent + token/time-cheap).
import { readFileSync, statSync, readdirSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { basename } from 'node:path';
import { parseLine, PARSER_VERSION } from './transcript.js';

const FILE_TOOLS = new Set(['Read', 'Edit', 'Write', 'NotebookEdit', 'MultiEdit']);
const sig = (s) => createHash('sha1').update(s.slice(0, 256)).digest('hex');

export function decodeSlug(slug) { return slug.replace(/^-/, '/').replace(/-/g, '/'); }

// worktree/wf cwd -> owning project root (strip at /.claude/worktrees/...).
export function canonProject(cwd) {
  const i = cwd.indexOf('/.claude/worktrees/');
  return i > 0 ? cwd.slice(0, i) : cwd;
}

// Discover every .jsonl under a project dir, tagged subagent/parent/agentId.
export function walkTranscripts(projDir) {
  const rels = readdirSync(projDir, { recursive: true }).filter((p) => typeof p === 'string' && p.endsWith('.jsonl'));
  return rels.map((rel) => {
    const norm = rel.replace(/\\/g, '/');
    const parts = norm.split('/');
    const si = parts.indexOf('subagents');
    if (si > 0) return { file: projDir + '/' + rel, subagent: true, parent: parts[si - 1], agentId: basename(norm).replace(/\.jsonl$/, '') };
    return { file: projDir + '/' + rel, subagent: false, parent: null, agentId: null };
  });
}

function resolveProject(events, slug) {
  for (const ev of events) if (ev && ev.ok && ev.cwd) { const p = canonProject(ev.cwd); return { path: p, label: basename(p) }; }
  const p = canonProject(decodeSlug(slug));
  return { path: p, label: basename(p) || slug };
}

// Pure projector: parsed Event -> the delta record streamed to the live UI/SSE.
// Mirrors the event columns but adds resolved tool file paths + bounded text.
function projectEvent(ev, projPath, uuid, agentId) {
  const u = ev.usage || {};
  const tools = ev.tools.map((t) => ({
    name: t.name || '',
    file: (FILE_TOOLS.has(t.name) && t.input && typeof t.input.file_path === 'string') ? t.input.file_path : null,
  }));
  return {
    uuid, ts: ev.ts, session: ev.session, project: projPath, agent: agentId || null,
    role: ev.role, model: ev.model, skill: ev.skill,
    in: u.in | 0, out: u.out | 0, cache_r: u.cache_r | 0, cache_w: u.cache_w | 0,
    n_tools: ev.tools.length, n_errors: ev.errors | 0,
    tools, text: ev.text ? ev.text.slice(0, 200) : (ev.title || ''),
  };
}

// Build graph for ONE event. Subject = dispatch node (subagent) or session node
// (main thread); usage edges attach to subject so per-agent work is navigable.
// Returns {session, proj:Projection} for live streaming, or null when skipped.
function addEvent(store, ev, proj, lineNo, meta) {
  const projId = 'project:' + proj.path;
  store.node('project', proj.path, proj.label, proj.path, ev.ts);
  const uuid = ev.uuid || (ev.session ? ev.session + '#' + (meta.agentId || '') + '#' + lineNo : 'anon:' + proj.path + '#' + lineNo);
  store.event({
    uuid, session: ev.session, project: proj.path, ts: ev.ts, etype: ev.etype,
    role: ev.role, model: ev.model, usage: ev.usage, skill: ev.skill,
    n_tools: ev.tools.length, n_errors: ev.errors, agent: meta.subagent ? meta.agentId : null,
    data: ev.text ? ev.text.slice(0, 4000) : (ev.title || null),
  });
  let subId;
  if (meta.subagent) {
    subId = store.node('dispatch', meta.agentId, 'agent ' + meta.agentId, proj.path, ev.ts, { parent: meta.parent, agentId: meta.agentId });
  } else {
    if (!ev.session) return null;
    subId = store.node('session', ev.session, ev.title || null, proj.path, ev.ts);
  }
  store.edge(subId, projId, 'in_project');
  if (ev.model) store.edge(subId, store.node('model', ev.model, ev.model), 'used_model');
  if (ev.skill) store.edge(subId, store.node('skill', ev.skill, ev.skill), 'used_skill');
  for (const t of ev.tools) {
    if (!t.name) continue;
    store.edge(subId, store.node('tool', t.name, t.name), 'used_tool');
    if (FILE_TOOLS.has(t.name) && t.input && typeof t.input.file_path === 'string') {
      const fp = t.input.file_path;
      store.edge(subId, store.node('file', fp, basename(fp), proj.path), 'touched_file');
    }
  }
  return { session: ev.session, proj: projectEvent(ev, proj.path, uuid, meta.subagent ? meta.agentId : null) };
}

// Incremental ingest of ONE transcript. meta={subagent,parent,agentId}.
export function ingestFile(store, file, slug, meta = { subagent: false, parent: null, agentId: null }) {
  const st0 = statSync(file);
  const size = st0.size, mtime = Math.floor(st0.mtimeMs);
  const prev = store.getState(file);
  const pverMatch = prev != null && (prev.pver ?? 0) === PARSER_VERSION;
  if (prev && prev.size === size && prev.mtime === mtime && pverMatch) return { skipped: true, processed: 0, events: [] };
  const raw = readFileSync(file, 'utf8');
  const lines = raw.split('\n');
  // nReal excludes the phantom trailing '' from a final newline; it is the
  // resume offset. Using lines.length would skip the first appended line.
  const nReal = lines.length > 0 && lines[lines.length - 1] === '' ? lines.length - 1 : lines.length;
  const s = sig(raw);
  let start = (pverMatch && prev && prev.sig === s && nReal >= prev.lines) ? prev.lines : 0;
  const slice = lines.slice(start);
  const parsed = slice.map((l) => parseLine(l));
  const proj = resolveProject(parsed, slug);
  let n = 0;
  const events = [];
  store.tx(() => {
    for (let i = 0; i < parsed.length; i++) {
      const ev = parsed[i];
      if (!ev || ev.ok === false) continue;
      const r = addEvent(store, ev, proj, start + i, meta);
      if (r) events.push(r.proj);
      n++;
    }
    // link parent session -> this dispatch (subagent run keyed by agentId)
    if (meta.subagent && meta.parent && n > 0) {
      store.node('session', meta.parent, null, proj.path);
      store.edge('session:' + meta.parent, 'dispatch:' + meta.agentId, 'dispatched', 1, { agentId: meta.agentId });
    }
    store.setState(file, size, mtime, nReal, s, PARSER_VERSION);
  });
  return { skipped: false, processed: n, project: proj.path, subagent: meta.subagent, events };
}

// Resolve ONE absolute file path -> tagging meta (mirrors walkTranscripts) so the
// watcher can ingest a single changed file without rescanning the project tree.
export function fileMeta(root, abs) {
  const rel = abs.startsWith(root + '/') ? abs.slice(root.length + 1) : abs;
  const parts = rel.replace(/\\/g, '/').split('/');
  const slug = parts[0];
  const si = parts.indexOf('subagents');
  if (si > 0) return { slug, file: abs, subagent: true, parent: parts[si - 1], agentId: basename(abs).replace(/\.jsonl$/, '') };
  return { slug, file: abs, subagent: false, parent: null, agentId: null };
}

export function ingestProject(store, projDir, slug) {
  if (!existsSync(projDir)) return { files: 0, touched: 0, processed: 0 };
  const items = walkTranscripts(projDir);
  let processed = 0, touched = 0;
  for (const it of items) {
    const r = ingestFile(store, it.file, slug, it);
    processed += r.processed;
    if (!r.skipped) touched++;
  }
  return { files: items.length, touched, processed };
}

export function ingestAll(store, root) {
  const slugs = readdirSync(root).filter((d) => existsSync(root + '/' + d) && statSync(root + '/' + d).isDirectory());
  const out = {};
  for (const slug of slugs) out[slug] = ingestProject(store, root + '/' + slug, slug);
  return out;
}
