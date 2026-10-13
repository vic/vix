// query.js — agent+UI facing read layer over the graph. Pure: (Store,args)->data.
// Includes FTS5 search-index builder (rebuilt post-ingest; cheap).
import { createHash } from 'node:crypto';
import { mineLessons } from './learn-mine.js';
import { writeLesson } from './writeback.js';

// ---- search index (FTS5 over titles + prompts + assistant text + files) ----
export function buildSearchIndex(s) {
  // Atomic rebuild: DROP+CREATE+populate in ONE transaction so concurrent
  // readers (MCP, web) see the OLD index until COMMIT — never an empty window.
  const ins0 = () => s.db.prepare('INSERT INTO search(ref,kind,project,body) VALUES(?,?,?,?)');
  s.db.exec('BEGIN');
  try {
  s.db.exec('DROP TABLE IF EXISTS search');
  s.db.exec(`CREATE VIRTUAL TABLE search USING fts5(ref UNINDEXED, kind UNINDEXED, project UNINDEXED, body)`);
  const ins = ins0();
  for (const r of s.all("SELECT id,label,project FROM node WHERE kind='session' AND label IS NOT NULL"))
    ins.run(r.id, 'session', r.project, r.label);
  for (const r of s.all("SELECT id,label,project FROM node WHERE kind='file' AND label IS NOT NULL"))
    ins.run(r.id, 'file', r.project, r.label);
  for (const r of s.all("SELECT id,label,project,data FROM node WHERE kind IN ('acronym','decision','concept')")) {
    let d = {}; try { d = r.data ? JSON.parse(r.data) : {}; } catch {}
    ins.run(r.id, r.id.split(':')[0], r.project, [r.label, d.def, d.text].filter(Boolean).join(' '));
  }
  for (const r of s.all("SELECT id,project,data FROM node WHERE kind='lesson'")) {
    let d = {}; try { d = r.data ? JSON.parse(r.data) : {}; } catch {}
    ins.run(r.id, 'lesson', r.project, [d.signature, d.resolution, d.trigger].filter(Boolean).join(' '));
  }
  // meaningful text events (user asks, titles, assistant prose) — skip tool noise
  for (const r of s.all(`SELECT uuid,session,project,etype,data FROM event
       WHERE data IS NOT NULL AND etype IN ('user','last-prompt','ai-title','assistant')`))
    ins.run(r.uuid, 'event:' + r.etype, r.project, r.data);
  s.db.exec('COMMIT');
  } catch (e) { try { s.db.exec('ROLLBACK'); } catch {} throw e; }
  return s.get('SELECT count(*) c FROM search').c;
}

const esc = (q) => '"' + String(q).replace(/"/g, '""') + '"'; // FTS5 phrase-safe

export function search(s, q, { project = null, limit = 25 } = {}) {
  if (!q || !q.trim()) return [];
  const has = s.get("SELECT 1 FROM sqlite_master WHERE name='search'");
  if (!has) return [];
  const where = project ? ' AND project=?' : '';
  const args = project ? [esc(q), project, limit] : [esc(q), limit];
  return s.all(
    `SELECT ref, kind, project, snippet(search, 3, '[', ']', ' … ', 12) snip, bm25(search) rank
     FROM search WHERE search MATCH ?${where} ORDER BY rank LIMIT ?`, ...args);
}

// ---- project name resolution (substring on path/label) ----
export function resolveProject(s, name) {
  if (!name) return null;
  const exact = s.get('SELECT id,label,project FROM node WHERE kind=? AND project=?', 'project', name);
  if (exact) return exact.project;
  const row = s.get(`SELECT project FROM node WHERE kind='project' AND (project LIKE ? OR label=?) ORDER BY length(project) LIMIT 1`,
    '%/' + name, name);
  return row ? row.project : null;
}

const burnCols = 'sum(in_tok) in_tok, sum(out_tok) out_tok, sum(cache_r) cache_r, sum(cache_w) cache_w, count(*) events';

export function status(s) {
  const nodes = {};
  for (const r of s.all('SELECT kind,count(*) c FROM node GROUP BY kind')) nodes[r.kind] = r.c;
  const burn = s.get(`SELECT ${burnCols} FROM event`);
  const projects = s.all(`SELECT project, sum(in_tok+out_tok) burn, count(*) events,
      count(DISTINCT session) sessions FROM event WHERE project IS NOT NULL
      GROUP BY project ORDER BY burn DESC`);
  return {
    nodes, edges: s.get('SELECT count(*) c FROM edge').c, files: s.get('SELECT count(*) c FROM ingest_state').c,
    events: burn.events, burn, projects,
  };
}

export function projectSummary(s, name) {
  const p = resolveProject(s, name);
  if (!p) return { error: 'no project matching ' + name, projects: s.all("SELECT label FROM node WHERE kind='project'").map((r) => r.label) };
  const burn = s.get(`SELECT ${burnCols}, count(DISTINCT session) sessions, count(DISTINCT agent) dispatches FROM event WHERE project=?`, p);
  const titles = s.all(`SELECT label, ts FROM node WHERE kind='session' AND project=? AND label IS NOT NULL ORDER BY ts DESC LIMIT 20`, p);
  const topTools = s.all(`SELECT dst, sum(weight) w FROM edge WHERE rel='used_tool' AND src IN
     (SELECT id FROM node WHERE project=? AND kind IN ('session','dispatch')) GROUP BY dst ORDER BY w DESC LIMIT 12`, p);
  const topSkills = s.all(`SELECT dst, sum(weight) w FROM edge WHERE rel='used_skill' AND src IN
     (SELECT id FROM node WHERE project=? AND kind IN ('session','dispatch')) GROUP BY dst ORDER BY w DESC LIMIT 12`, p);
  const topFiles = s.all(`SELECT dst, sum(weight) w FROM edge WHERE rel='touched_file' AND src IN
     (SELECT id FROM node WHERE project=? AND kind IN ('session','dispatch')) GROUP BY dst ORDER BY w DESC LIMIT 15`, p);
  const byModel = s.all(`SELECT model, count(DISTINCT agent) runs, sum(out_tok) out_tok FROM event
     WHERE project=? AND agent IS NOT NULL GROUP BY model ORDER BY out_tok DESC`, p);
  const acr = s.all("SELECT label,data FROM node WHERE kind='acronym' AND project=? ORDER BY label LIMIT 50", p)
    .map((r) => ({ term: r.label, def: parseData(r).def || '' }));
  const open = s.all("SELECT data FROM node WHERE kind='decision' AND project=? AND label LIKE 'OPEN:%' LIMIT 40", p)
    .map((r) => parseData(r).text).filter(Boolean);
  const lawN = s.get("SELECT count(*) c FROM node WHERE kind='decision' AND project=? AND label LIKE 'LAW:%'", p).c;
  return {
    project: p, burn,
    titles: titles.map((t) => t.label),
    open, statusCounts: { law: lawN, open: open.length },
    acronyms: acr,
    topTools: topTools.map((r) => ({ tool: r.dst.replace('tool:', ''), uses: r.w })),
    topSkills: topSkills.map((r) => ({ skill: r.dst.replace('skill:', ''), uses: r.w })),
    topFiles: topFiles.map((r) => ({ file: r.dst.replace('file:', ''), touches: r.w })),
    dispatchBurn: byModel,
  };
}

export function sessions(s, { project = null, limit = 20 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const where = p ? 'WHERE n.project=?' : '';
  const args = p ? [p, limit] : [limit];
  return s.all(`SELECT n.id session, n.label title, n.project, n.ts,
     (SELECT model FROM event e WHERE e.session=substr(n.id,9) AND e.model IS NOT NULL LIMIT 1) model,
     (SELECT sum(in_tok+out_tok) FROM event e WHERE e.session=substr(n.id,9)) burn,
     (SELECT count(*) FROM event e WHERE e.session=substr(n.id,9)) events
     FROM node n WHERE n.kind='session' ${where ? 'AND' + where.slice(5) : ''}
     ORDER BY n.ts DESC LIMIT ?`, ...args);
}

// dispatched-agent telemetry: per-agent model + burn + tool count (token routing)
export function dispatches(s, { project = null, limit = 40 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const where = p ? 'WHERE project=?' : '';
  const args = p ? [p, limit] : [limit];
  return s.all(`SELECT agent, project,
     (SELECT model FROM event e2 WHERE e2.agent=e.agent AND e2.model IS NOT NULL LIMIT 1) model,
     sum(out_tok) out_tok, sum(in_tok) in_tok, sum(n_tools) tools, count(*) events
     FROM event e ${where} ${where ? 'AND' : 'WHERE'} agent IS NOT NULL
     GROUP BY agent ORDER BY out_tok DESC LIMIT ?`, ...args)
    // runaway = under-partitioned dispatch (supervisor-law): huge burn or tool count.
    .map((r) => ({ ...r, runaway: r.out_tok > 80000 || r.tools > 100 }));
}

export function modelBurn(s) {
  return s.all(`SELECT COALESCE(model,'(none)') model,
     count(*) events, sum(in_tok) in_tok, sum(out_tok) out_tok,
     count(DISTINCT CASE WHEN agent IS NOT NULL THEN agent END) dispatch_runs
     FROM event GROUP BY model ORDER BY out_tok DESC`);
}

// workflow-health report: routing audit + runaway + cache + tool adoption + recs.
export function health(s) {
  const burn = s.get(`SELECT ${burnCols} FROM event`);
  const models = s.all(`SELECT COALESCE(model,'(none)') model, sum(out_tok) out_tok,
     count(DISTINCT CASE WHEN agent IS NOT NULL THEN agent END) runs FROM event
     WHERE model NOT IN ('<synthetic>') OR model IS NULL GROUP BY model ORDER BY out_tok DESC`);
  const totalOut = models.reduce((a, m) => a + (m.out_tok || 0), 0) || 1;
  const routing = models.filter((m) => m.runs > 0).map((m) => ({
    model: m.model, runs: m.runs, out_tok: m.out_tok,
    out_per_run: Math.round(m.out_tok / m.runs), share_pct: +(100 * m.out_tok / totalOut).toFixed(1),
  }));
  const runaway = s.all(`SELECT agent, project, sum(out_tok) out_tok, sum(n_tools) tools FROM event
     WHERE agent IS NOT NULL GROUP BY agent HAVING out_tok>80000 OR tools>100`);
  const tool = (n) => s.get("SELECT COALESCE(sum(weight),0) w FROM edge WHERE rel='used_tool' AND dst=?", 'tool:' + n).w;
  const cg = s.get("SELECT COALESCE(sum(weight),0) w FROM edge WHERE rel='used_tool' AND dst LIKE 'tool:mcp__codegraph__%'").w;
  const reads = tool('Read');
  const unlabeled = s.get("SELECT count(*) c FROM node WHERE kind='session' AND label IS NULL").c;
  const sessions = s.get("SELECT count(*) c FROM node WHERE kind='session'").c;
  const recs = [];
  const opus = routing.find((r) => /opus/.test(r.model));
  if (opus && opus.share_pct > 50) recs.push(`opus = ${opus.share_pct}% of dispatch burn over ${opus.runs} runs — audit for spec-tight tasks that fit sonnet (T1).`);
  if (runaway.length) recs.push(`${runaway.length} runaway dispatches (>80k out or >100 tools) — partition into oracle-gated rungs (T2).`);
  if (reads > cg * 10) recs.push(`Read:codegraph = ${Math.round(reads / Math.max(cg, 1))}:1 — codegraph under-adopted vs mandate (T3).`);
  const cacheRatio = +(burn.cache_r / Math.max(burn.in_tok, 1)).toFixed(1);
  if (cacheRatio > 50) recs.push(`cache reuse ${cacheRatio}x — HEALTHY, do not touch.`);
  const errAgg = s.get('SELECT sum(n_errors) total_errors, count(*) events FROM event');
  const total_errors = errAgg.total_errors || 0;
  const error_rate = errAgg.events > 0 ? +(total_errors / errAgg.events).toFixed(4) : 0;
  return {
    burn, cache_read_input_ratio: cacheRatio, routing,
    runaway_count: runaway.length, runaway_top: runaway.sort((a, b) => b.out_tok - a.out_tok).slice(0, 8),
    tool_adoption: { Read: reads, codegraph: cg, ratio: Math.round(reads / Math.max(cg, 1)) },
    sessions, unlabeled, total_errors, error_rate, recommendations: recs,
  };
}

export function concept(s, term) {
  const hits = search(s, term, { limit: 30 });
  const byProject = {};
  for (const h of hits) { const k = h.project || '?'; (byProject[k] ||= []).push({ kind: h.kind, ref: h.ref, snip: h.snip }); }
  return { term, occurrences: hits.length, byProject };
}

function parseData(row) { try { return row.data ? JSON.parse(row.data) : {}; } catch { return {}; } }

export function acronyms(s, { project = null, limit = 200 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const rows = p
    ? s.all("SELECT label,data,project FROM node WHERE kind='acronym' AND project=? ORDER BY label LIMIT ?", p, limit)
    : s.all("SELECT label,data,project FROM node WHERE kind='acronym' ORDER BY label LIMIT ?", limit);
  return rows.map((r) => ({ term: r.label, def: parseData(r).def || '', project: r.project }));
}

export function decisions(s, { project = null, status = null, limit = 100 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const clauses = [], args = [];
  if (p) { clauses.push('project=?'); args.push(p); }
  if (status) { clauses.push('label LIKE ?'); args.push(status.toUpperCase() + ':%'); }
  const where = clauses.length ? 'AND ' + clauses.join(' AND ') : '';
  args.push(limit);
  return s.all(`SELECT label,data,project FROM node WHERE kind='decision' ${where} ORDER BY label LIMIT ?`, ...args)
    .map((r) => { const d = parseData(r); return { status: d.status, text: d.text, project: r.project, file: d.file }; });
}

export function remaining(s, project) {
  return decisions(s, { project, status: 'OPEN', limit: 100 });
}

// Error-rate report: sessions/projects ranked by error count.
// NOTE: n_errors is stored per-event (one event = one message). The event schema
// records how many tool_result blocks in that message had is_error:true. We do NOT
// have per-tool-name error attribution because tool_result blocks carry only a
// tool_use_id, not the tool name, and OMNI does not join those IDs. Per-session
// and per-project aggregation is the finest grain cleanly supported by the schema.
export function errors(s, { project = null, limit = 20 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const where = p ? 'WHERE project=?' : '';
  const args = p ? [p, limit] : [limit];
  const by_session = s.all(
    `SELECT session, project, sum(n_errors) total_errors, count(*) events
     FROM event ${where} GROUP BY session HAVING total_errors > 0
     ORDER BY total_errors DESC LIMIT ?`, ...args);
  const projWhere = p ? 'WHERE project=? AND project IS NOT NULL' : 'WHERE project IS NOT NULL';
  const projArgs = p ? [p, limit] : [limit];
  const by_project = s.all(
    `SELECT project, sum(n_errors) total_errors, count(*) events
     FROM event ${projWhere} GROUP BY project HAVING total_errors > 0
     ORDER BY total_errors DESC LIMIT ?`, ...projArgs);
  const agg = s.get(`SELECT sum(n_errors) total_errors, count(*) events FROM event ${where}`,
    ...(p ? [p] : []));
  const total_errors = agg.total_errors || 0;
  const events = agg.events || 0;
  const error_rate = events > 0 ? +(total_errors / events).toFixed(4) : 0;
  return { total_errors, events, error_rate, by_session, by_project };
}

export function fileHotspots(s, { project = null, limit = 20 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const where = p ? 'WHERE n.project=?' : '';
  const args = p ? [p, limit] : [limit];
  return s.all(`SELECT n.label file, n.project, sum(e.weight) touches FROM edge e
     JOIN node n ON n.id=e.dst WHERE e.rel='touched_file' ${where ? 'AND' + where.slice(5) : ''}
     GROUP BY n.id ORDER BY touches DESC LIMIT ?`, ...args);
}

// subgraph for visualization (bounded)
export function graph(s, { project = null, limit = 400 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  let nodes, edges;
  if (p) {
    nodes = s.all(`SELECT id,kind,label,project FROM node WHERE project=? AND kind IN
       ('project','session','dispatch','model','skill','tool','file') LIMIT ?`, p, limit);
    const ids = new Set(nodes.map((n) => n.id));
    edges = s.all(`SELECT src,dst,rel,weight FROM edge WHERE src IN
       (SELECT id FROM node WHERE project=?) LIMIT ?`, p, limit * 4).filter((e) => ids.has(e.src) && ids.has(e.dst));
  } else {
    // global: projects + models + skills, with AGGREGATE project->model/skill edges
    // (raw used_model edges originate at session/dispatch nodes, not shown here).
    nodes = s.all(`SELECT id,kind,label,project FROM node WHERE kind IN ('project','model','skill') LIMIT ?`, limit);
    const ids = new Set(nodes.map((n) => n.id));
    edges = [];
    for (const rel of ['used_model', 'used_skill']) {
      for (const r of s.all(`SELECT n.project proj, e.dst dst, sum(e.weight) weight FROM edge e
           JOIN node n ON n.id=e.src WHERE e.rel=? AND n.project IS NOT NULL GROUP BY n.project, e.dst`, rel)) {
        const src = 'project:' + r.proj;
        if (ids.has(src) && ids.has(r.dst)) edges.push({ src, dst: r.dst, rel, weight: r.weight });
      }
    }
  }
  return { nodes, edges };
}

// ---- word frequency (for the word force-graph) ----
// Tokenize meaningful event text (user/assistant/title prompts), drop stopwords,
// return top-N {word,count}. JS tokenize over a bounded recent window (ts DESC).
const STOP = new Set((
  'the a an and or but if then else of to in on at for with from by as is are was were ' +
  'be been being do does did done has have had will would can could should may might must ' +
  'this that these those it its it\'s they them their there here what which who whom whose ' +
  'you your yours we our ours us i me my mine he she his her him not no yes so up out off ' +
  'about into over under again more most some any all each both few how when where why ' +
  'just like also only than too very get got let use used using one two three new now via ' +
  'http https www com org net file files line lines code true false null undefined function ' +
  'const let var return import export class async await this run see need want make made set'
).split(' '));

export function words(s, { project = null, limit = 80 } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const where = p ? 'AND project=?' : '';
  const args = p ? [p, 4000] : [4000];
  const rows = s.all(`SELECT substr(data,1,2000) data FROM event
     WHERE data IS NOT NULL AND etype IN ('user','last-prompt','ai-title','assistant') ${where}
     ORDER BY ts DESC LIMIT ?`, ...args);
  const freq = new Map();
  for (const r of rows) {
    const toks = (r.data || '').toLowerCase().match(/[a-z][a-z0-9_]{2,}/g);
    if (!toks) continue;
    for (const t of toks) { if (STOP.has(t) || t.length > 24) continue; freq.set(t, (freq.get(t) || 0) + 1); }
  }
  return [...freq.entries()].sort((a, b) => b[1] - a[1]).slice(0, limit).map(([word, count]) => ({ word, count }));
}

// ---- token burn over time (for the burnout timeline) ----
// Per-day buckets of in/out tokens + event/session counts, ascending by day.
export function burnSeries(s, { project = null } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const where = p ? 'WHERE project=? AND ts IS NOT NULL' : 'WHERE ts IS NOT NULL';
  const args = p ? [p] : [];
  return s.all(`SELECT substr(ts,1,10) day, sum(in_tok) in_tok, sum(out_tok) out_tok,
     count(*) events, count(DISTINCT session) sessions
     FROM event ${where} GROUP BY day ORDER BY day ASC`, ...args);
}

// ---- live windows: token burn bucketed over a window back from NOW (UTC) ----
// window 1h/5h/1d/1w; bucket minute|hour|day (substr on ISO ts). NOW-anchored so
// idle shows empty trailing buckets (true live). Unknown window/bucket -> [].
const WIN_MS = { '1h': 3600e3, '5h': 5 * 3600e3, '1d': 86400e3, '1w': 7 * 86400e3 };
const BUCKET_LEN = { minute: 16, hour: 13, day: 10 };
const DEFAULT_BUCKET = { '1h': 'minute', '5h': 'hour', '1d': 'hour', '1w': 'day' };

export function burnWindow(s, { window = '1d', bucket = null, project = null, model = null } = {}) {
  const ms = WIN_MS[window]; if (!ms) return [];
  const bk = bucket || DEFAULT_BUCKET[window]; const len = BUCKET_LEN[bk]; if (!len) return [];
  const cutoff = new Date(Date.now() - ms).toISOString();
  const f = evFilter(s, { project, model }, ['ts >= ?']);
  const where = f.where, args = [cutoff, ...f.args];
  return s.all(`SELECT substr(ts,1,${len}) bucket, sum(in_tok) in_tok, sum(out_tok) out_tok,
     sum(in_tok)+sum(out_tok) total, count(*) events
     FROM event ${where} GROUP BY bucket ORDER BY bucket ASC`, ...args)
    .map((r) => ({ bucket: r.bucket, in_tok: r.in_tok || 0, out_tok: r.out_tok || 0, total: r.total || 0, events: r.events }));
}

// ---- live token-RATE (network-monitor): bin recent events into binSec bins ----
// Fills empty bins with zeros so the meter shows idle gaps. JS binning (epoch).
export function rollingRate(s, { spanMin = 60, binSec = 60, project = null, model = null } = {}) {
  const span = Math.max(1, Math.min(spanMin | 0 || 60, 1440));
  const bin = Math.max(5, binSec | 0 || 60);
  const now = Date.now();
  const cutoff = new Date(now - span * 60000).toISOString();
  const f = evFilter(s, { project, model }, ['ts >= ?']);
  const where = f.where, args = [cutoff, ...f.args];
  const rows = s.all(`SELECT ts, in_tok, out_tok FROM event ${where} ORDER BY ts ASC`, ...args);
  const start = Math.floor((now - span * 60000) / 1000 / bin) * bin;
  const n = Math.ceil((span * 60) / bin) + 1;
  const bins = Array.from({ length: n }, (_, i) => ({ t: new Date((start + i * bin) * 1000).toISOString(), in_tok: 0, out_tok: 0, total: 0 }));
  for (const r of rows) {
    const idx = Math.floor((Date.parse(r.ts) / 1000 - start) / bin);
    if (idx >= 0 && idx < n) { bins[idx].in_tok += r.in_tok || 0; bins[idx].out_tok += r.out_tok || 0; }
  }
  for (const b of bins) b.total = b.in_tok + b.out_tok;
  return { spanMin: span, binSec: bin, bins };
}

// ---- plan utilization: rolling 5h + weekly token sums vs caps ("am I maxing it?") ----
// Caps are USER CONFIG (env OMNI_CAP_5H / OMNI_CAP_WEEK or query param) — exact Claude
// quotas are not public, so % only shows when a cap is provided. Token sums are always real.
// resetInMs = when the oldest token in the rolling window ages out.
const CAP_5H = process.env.OMNI_CAP_5H ? +process.env.OMNI_CAP_5H : null;
const CAP_WEEK = process.env.OMNI_CAP_WEEK ? +process.env.OMNI_CAP_WEEK : null;

export function planUtilization(s, { project = null, cap5h = CAP_5H, capWeek = CAP_WEEK } = {}) {
  const p = project ? resolveProject(s, project) : null;
  const now = Date.now();
  // current pace = tokens in the last hour -> forward burn rate for exhaustion forecast
  const recWhere = p ? 'WHERE ts >= ? AND project=?' : 'WHERE ts >= ?';
  const recCut = new Date(now - 3600e3).toISOString();
  const ratePerHr = s.get(`SELECT sum(in_tok+out_tok) t FROM event ${recWhere}`, ...(p ? [recCut, p] : [recCut])).t || 0;
  const ratePerMs = ratePerHr / 3600e3;
  const win = (ms, cap) => {
    const cutoff = new Date(now - ms).toISOString();
    const where = p ? 'WHERE ts >= ? AND project=?' : 'WHERE ts >= ?';
    const args = p ? [cutoff, p] : [cutoff];
    const r = s.get(`SELECT sum(in_tok) in_tok, sum(out_tok) out_tok, count(*) events, min(ts) first_ts FROM event ${where}`, ...args);
    const tok = (r.in_tok || 0) + (r.out_tok || 0);
    return {
      tokens: tok, in_tok: r.in_tok || 0, out_tok: r.out_tok || 0, events: r.events || 0,
      cap: cap || null, pct: cap ? +(100 * tok / cap).toFixed(1) : null,
      resetInMs: r.first_ts ? Math.max(0, Date.parse(r.first_ts) + ms - now) : 0,
      // forecast: ms until this window's allowance is exhausted at the current hourly pace
      etaMs: (cap && ratePerMs > 0) ? Math.max(0, Math.round((cap - tok) / ratePerMs)) : null,
    };
  };
  return { rate_per_hr: Math.round(ratePerHr), window5h: win(WIN_MS['5h'], cap5h), week: win(WIN_MS['1w'], capWeek), capConfigured: !!(cap5h || capWeek) };
}

// ---- $ pricing (claude-api 2026-06, $/1M in,out) + KPIs ----
const PRICE = { fable: [10, 50], mythos: [10, 50], opus: [5, 25], sonnet: [3, 15], haiku: [1, 5] };
function priceFor(model) {
  const m = (model || '').toLowerCase();
  for (const k of ['fable', 'mythos', 'opus', 'sonnet', 'haiku']) if (m.includes(k)) return PRICE[k];
  return null; // unknown model -> excluded from $ estimate
}
// cache_r ~0.1x input, cache_w ~1.25x input (prompt-caching economics)
function dollarsOf(i, o, cr, cw, model) {
  const pr = priceFor(model); if (!pr) return 0;
  return (i * pr[0] + o * pr[1] + (cr || 0) * pr[0] * 0.1 + (cw || 0) * pr[0] * 1.25) / 1e6;
}

// Per-event $ helpers (exported): one from a live Projection, one from a DB row.
export { dollarsOf, priceFor };
export function eventCost(ev) { return dollarsOf(ev.in | 0, ev.out | 0, ev.cache_r | 0, ev.cache_w | 0, ev.model); }
export function eventCostRow(r) { return dollarsOf(r.in_tok | 0, r.out_tok | 0, r.cache_r | 0, r.cache_w | 0, r.model); }

// Build a WHERE clause over the `event` table from a project + model filter.
// model is a case-insensitive substring (e.g. 'opus'); extra = extra clause strings.
function evFilter(s, { project = null, model = null } = {}, extra = []) {
  const p = project ? resolveProject(s, project) : null;
  const clauses = [...extra], args = [];
  if (p) { clauses.push('project=?'); args.push(p); }
  if (model) { clauses.push('model LIKE ?'); args.push('%' + model + '%'); }
  return { p, where: clauses.length ? 'WHERE ' + clauses.join(' AND ') : '', clauses, args };
}

export function kpis(s, { project = null, model = null } = {}) {
  const f = evFilter(s, { project, model });
  const pw = f.where, pa = f.args;
  const byModel = s.all(`SELECT COALESCE(model,'(none)') model, sum(in_tok) i, sum(out_tok) o,
     sum(cache_r) cr, sum(cache_w) cw, count(*) events FROM event ${pw} GROUP BY model`, ...pa);
  let usd = 0, inTok = 0, outTok = 0, cacheR = 0;
  for (const m of byModel) { usd += dollarsOf(m.i, m.o, m.cr, m.cw, m.model); inTok += m.i || 0; outTok += m.o || 0; cacheR += m.cr || 0; }
  const sessions = s.get(`SELECT count(DISTINCT session) c FROM event ${pw}`, ...pa).c || 1;
  const cut24 = new Date(Date.now() - 86400e3).toISOString();
  const w24 = 'WHERE ts>=?' + (f.clauses.length ? ' AND ' + f.clauses.join(' AND ') : '');
  const a24 = [cut24, ...pa];
  const r24 = s.get(`SELECT sum(in_tok+out_tok) t FROM event ${w24}`, ...a24);
  const err = s.get(`SELECT sum(n_errors) e, count(*) ev FROM event ${pw}`, ...pa);
  const topBy = (col) => {
    const rows = s.all(`SELECT ${col} k, model, sum(in_tok) i, sum(out_tok) o, sum(cache_r) cr, sum(cache_w) cw
       FROM event ${pw} ${pw ? 'AND' : 'WHERE'} ${col} IS NOT NULL GROUP BY ${col}, model`, ...pa);
    const agg = {};
    for (const r of rows) { (agg[r.k] ||= { k: r.k, usd: 0, tok: 0 }); agg[r.k].usd += dollarsOf(r.i, r.o, r.cr, r.cw, r.model); agg[r.k].tok += (r.i || 0) + (r.o || 0); }
    return Object.values(agg).sort((a, b) => b.usd - a.usd).slice(0, 8).map((x) => ({ k: x.k, usd: +x.usd.toFixed(2), tok: x.tok }));
  };
  return {
    usd: +usd.toFixed(2), in_tok: inTok, out_tok: outTok, cache_ratio: +(cacheR / Math.max(inTok, 1)).toFixed(1),
    sessions, tok_per_session: Math.round((inTok + outTok) / sessions), tok_per_hour_24h: Math.round((r24.t || 0) / 24),
    error_rate: err.ev ? +((err.e || 0) / err.ev).toFixed(4) : 0,
    by_model: byModel.map((m) => ({ model: m.model, in_tok: m.i || 0, out_tok: m.o || 0, events: m.events, usd: +dollarsOf(m.i, m.o, m.cr, m.cw, m.model).toFixed(2) })).sort((a, b) => b.usd - a.usd),
    top_sessions: topBy('session'), top_agents: topBy('agent'), top_projects: topBy('project'),
  };
}

// ---- timeline: recent per-event {session, ts, usd} for the swimlane view ----
export function timeline(s, { project = null, model = null, spanMs = 7 * 86400e3, limit = 4000 } = {}) {
  const cutoff = new Date(Date.now() - spanMs).toISOString();
  const f = evFilter(s, { project, model }, ['ts>=?', 'session IS NOT NULL']);
  const args = [cutoff, ...f.args, limit];
  const rows = s.all(`SELECT session, ts, model, in_tok, out_tok, cache_r, cache_w
     FROM event ${f.where} ORDER BY ts DESC LIMIT ?`, ...args);
  return rows.map((r) => ({ session: r.session, ts: r.ts, usd: +eventCostRow(r).toFixed(4) })).reverse();
}

// ---- routing flows: per (project, model) $ + tokens, with sonnet-downgrade $ ----
// Feeds the routing Sankey: width = $, candidates = expensive models that would be
// cheaper on sonnet (usd_sonnet < usd).
export function routingFlows(s, { project = null, model = null } = {}) {
  const f = evFilter(s, { project, model }, ['project IS NOT NULL', 'model IS NOT NULL']);
  const where = f.where, args = f.args;
  const rows = s.all(`SELECT project, model, sum(in_tok) i, sum(out_tok) o, sum(cache_r) cr,
     sum(cache_w) cw, count(*) ev FROM event ${where} GROUP BY project, model`, ...args);
  return rows.map((r) => {
    const usd = dollarsOf(r.i, r.o, r.cr, r.cw, r.model);
    const usdSonnet = dollarsOf(r.i, r.o, r.cr, r.cw, 'sonnet');
    return { project: r.project, model: r.model, usd: +usd.toFixed(2), tok: (r.i || 0) + (r.o || 0),
      events: r.ev, usd_sonnet: +usdSonnet.toFixed(2),
      downgrade: /opus|fable|mythos/.test(r.model || '') && usdSonnet < usd ? +(usd - usdSonnet).toFixed(2) : 0 };
  }).filter((f) => f.usd > 0).sort((a, b) => b.usd - a.usd);
}

// ---- burn punchcard: $ per (UTC weekday, hour) — "when does money burn?" ----
export function burnPunchcard(s, { project = null, model = null } = {}) {
  const f = evFilter(s, { project, model }, ['ts IS NOT NULL']);
  const rows = s.all(`SELECT ts, model, in_tok, out_tok, cache_r, cache_w FROM event ${f.where}`, ...f.args);
  const grid = {}; // key = dow*24 + hour
  for (const r of rows) {
    const d = new Date(r.ts); if (isNaN(d)) continue;
    const k = d.getUTCDay() * 24 + d.getUTCHours();
    (grid[k] ||= { dow: d.getUTCDay(), hour: d.getUTCHours(), usd: 0, tok: 0, events: 0 });
    grid[k].usd += eventCostRow(r); grid[k].tok += (r.in_tok | 0) + (r.out_tok | 0); grid[k].events++;
  }
  return Object.values(grid).map((g) => ({ ...g, usd: +g.usd.toFixed(4) }));
}

// ---- waste taxonomy: where tokens=$ are lost. Thresholds = corpus percentiles
// (data-driven, NO magic constants) so it adapts to each user's workload. ----
const EXPENSIVE = /opus|fable|mythos/;  // models warranting tight specs
const READ_CODEGRAPH_BASELINE = 10;     // Read:codegraph ratio above which reads are redundant

function pctile(arr, q) {
  if (!arr.length) return 0;
  const a = [...arr].sort((x, y) => x - y);
  const idx = (q / 100) * (a.length - 1);
  const lo = Math.floor(idx), hi = Math.ceil(idx);
  return lo === hi ? a[lo] : a[lo] + (a[hi] - a[lo]) * (idx - lo);
}

export function waste(s, { project = null, model = null, limit = 50 } = {}) {
  const f = evFilter(s, { project, model }, ['session IS NOT NULL']);
  const where = f.where, args = f.args;
  // per (session, model) aggregate -> lets us recompute $ at alternate prices.
  const sm = s.all(`SELECT session, model, sum(in_tok) i, sum(out_tok) o, sum(cache_r) cr,
     sum(cache_w) cw, sum(n_errors) errs, count(*) ev FROM event ${where} GROUP BY session, model`, ...args);
  const sess = {};
  for (const r of sm) {
    const z = (sess[r.session] ||= { id: r.session, in: 0, out: 0, cr: 0, cw: 0, errs: 0, ev: 0, usd: 0, topModel: null, topOut: -1 });
    z.in += r.i || 0; z.out += r.o || 0; z.cr += r.cr || 0; z.cw += r.cw || 0;
    z.errs += r.errs || 0; z.ev += r.ev || 0;
    z.usd += dollarsOf(r.i, r.o, r.cr, r.cw, r.model);
    if ((r.o || 0) > z.topOut) { z.topOut = r.o || 0; z.topModel = r.model; }
  }
  const list = Object.values(sess);
  const corpusErrRate = list.length ? list.reduce((a, z) => a + (z.ev ? z.errs / z.ev : 0), 0) / list.length : 0;
  const items = [];

  // W1 over-routed: expensive model + abnormally low out/event -> downgrade to sonnet.
  const expensive = list.filter((z) => z.topModel && EXPENSIVE.test(z.topModel));
  const opeThresh = pctile(expensive.map((z) => (z.ev ? z.out / z.ev : 0)), 25);
  for (const z of expensive) {
    const perEv = z.ev ? z.out / z.ev : 0;
    const errRate = z.ev ? z.errs / z.ev : 0;
    if (perEv < opeThresh && errRate <= corpusErrRate) {
      const lost = +(z.usd - dollarsOf(z.in, z.out, z.cr, z.cw, 'sonnet')).toFixed(4);
      if (lost > 0) items.push({ scope: 'session', id: z.id, reason: 'W1', usd_lost: lost,
        evidence: { model: z.topModel, out_per_event: Math.round(perEv), events: z.ev },
        action: `route → sonnet (save $${lost.toFixed(2)})` });
    }
  }

  // W2 under-routed: long OR error-prone haiku session -> consider sonnet (signal, $0).
  const lenThresh = pctile(list.map((z) => z.ev), 90);
  for (const z of list) {
    if (!z.topModel || !/haiku/.test(z.topModel)) continue;
    const errRate = z.ev ? z.errs / z.ev : 0;
    if (z.ev > lenThresh || errRate > corpusErrRate) {
      items.push({ scope: 'session', id: z.id, reason: 'W2', usd_lost: 0,
        evidence: { events: z.ev, errors: z.errs, error_rate: +errRate.toFixed(3) },
        action: 'consider sonnet (long/error-prone haiku run)' });
    }
  }

  // W3 cache leak: low cache reuse on a big-input session -> uncached premium burned.
  const ratThresh = pctile(list.filter((z) => z.in > 0).map((z) => z.cr / z.in), 50);
  for (const z of list) {
    if (z.in <= 10000) continue;
    const ratio = z.cr / z.in;
    if (ratio < ratThresh) {
      const pr = priceFor(z.topModel); if (!pr) continue;
      const lost = +Math.min(z.usd, z.in * pr[0] * 0.9 / 1e6).toFixed(4);
      if (lost > 0) items.push({ scope: 'session', id: z.id, reason: 'W3', usd_lost: lost,
        evidence: { in_tok: z.in, cache_ratio: +ratio.toFixed(2), model: z.topModel },
        action: 'enable/raise prompt cache' });
    }
  }

  // W4 redundant reads: corpus-level Read >> codegraph adoption (single item).
  const ta = health(s).tool_adoption || {};
  if (ta.Read > 0 && ta.Read > (ta.codegraph || 0) * READ_CODEGRAPH_BASELINE) {
    items.push({ scope: 'corpus', id: 'tool_adoption', reason: 'W4', usd_lost: 0,
      evidence: { read: ta.Read, codegraph: ta.codegraph || 0, ratio: ta.ratio },
      action: 'prefer codegraph over Read for structural queries' });
  }

  // W5 idle/stalled: tokens in, zero out -> billed input with no result.
  const idle = evFilter(s, { project, model }, ['session IS NOT NULL', 'in_tok>0', 'out_tok=0']);
  for (const r of s.all(`SELECT session, model, sum(in_tok) i, sum(cache_r) cr, sum(cache_w) cw, count(*) n
     FROM event ${idle.where} GROUP BY session`, ...idle.args)) {
    const lost = +dollarsOf(r.i, 0, r.cr, r.cw, r.model).toFixed(4);
    if (lost > 0) items.push({ scope: 'session', id: r.session, reason: 'W5', usd_lost: lost,
      evidence: { idle_events: r.n, in_tok: r.i, model: r.model },
      action: 'investigate stalled dispatch (input billed, no output)' });
  }

  items.sort((a, b) => b.usd_lost - a.usd_lost);
  const by_reason = { W1: 0, W2: 0, W3: 0, W4: 0, W5: 0 };
  let total = 0;
  for (const it of items) { by_reason[it.reason] += it.usd_lost; total += it.usd_lost; }
  for (const k of Object.keys(by_reason)) by_reason[k] = +by_reason[k].toFixed(2);
  return { total_lost_usd: +total.toFixed(2), by_reason, items: items.slice(0, limit) };
}

// ---- learning: materialize mined lessons into the graph ----
// Idempotent: id is a stable sha1 of (scope, type, signature). Returns count upserted.
const _upsertLesson = (s) => s.db.prepare(`INSERT INTO node(id,kind,label,project,ts,data) VALUES(?,?,?,?,?,?)
  ON CONFLICT(id) DO UPDATE SET
    label=COALESCE(excluded.label, node.label),
    project=COALESCE(excluded.project, node.project),
    ts=CASE WHEN excluded.ts>node.ts THEN excluded.ts ELSE node.ts END,
    data=COALESCE(excluded.data, node.data)`);

export function materializeLessons(s) {
  const lessons = mineLessons(s);
  if (!lessons.length) return 0;
  const stmt = _upsertLesson(s);
  const nowIso = new Date().toISOString();
  let count = 0;
  for (const lesson of lessons) {
    const hash = createHash('sha1')
      .update(lesson.scope + '\x1f' + lesson.type + '\x1f' + lesson.signature)
      .digest('hex');
    const id = 'lesson:' + hash;
    const label = lesson.signature.length > 120 ? lesson.signature.slice(0, 120) : lesson.signature;
    const project = lesson.scope === 'GLOBAL' ? null : lesson.scope;
    // Preserve first-seen ts: reuse existing ts so re-mining never buries old lessons.
    const existing = s.get('SELECT ts FROM node WHERE id=?', id);
    const ts = existing ? existing.ts : nowIso;
    stmt.run(id, 'lesson', label, project, ts, JSON.stringify(lesson));
    count++;
  }
  return count;
}

// ---- recall: query materialized lessons from the graph ----
export function recall(s, { scope = null, type = null, query = null, include_global = true, limit = 25 } = {}) {
  const rows = s.all("SELECT id,label,project,ts,data FROM node WHERE kind='lesson'");
  let results = [];
  for (const row of rows) {
    let d;
    try { d = row.data ? JSON.parse(row.data) : {}; } catch { d = {}; }
    if (scope) {
      if (!(d.scope === scope || (include_global && d.scope === 'GLOBAL'))) continue;
    } else {
      // No scope provided: return ONLY GLOBAL lessons (no project bleed)
      if (d.scope !== 'GLOBAL') continue;
    }
    if (type && d.type !== type) continue;
    if (query) {
      const q = query.toLowerCase();
      const sig = (d.signature || '').toLowerCase();
      const lbl = (row.label || '').toLowerCase();
      if (!sig.includes(q) && !lbl.includes(q)) continue;
    }
    results.push({
      _occ: (d.evidence && d.evidence.occurrences) || 1,
      _ts: row.ts || '',
      signature: d.signature || row.label || '',
      type: d.type || '',
      resolution: d.resolution || '',
      scope: d.scope || 'GLOBAL',
      occurrences: (d.evidence && d.evidence.occurrences) || 1,
      models: (d.evidence && d.evidence.models) || [],
      tentative: ((d.evidence && d.evidence.occurrences) || 1) < 2 || d.confidence === 'observed',
    });
  }
  results.sort((a, b) => (b._ts > a._ts ? 1 : b._ts < a._ts ? -1 : 0) || b._occ - a._occ);
  results = results.slice(0, limit);
  return results.map(({ _occ: _o, _ts: _t, ...rest }) => rest);
}

// ---- learn: capture + evidence-gated promotion ----
// Always upserts a T0 db node. Promotes to memory (T1) or skill (T2) when
// evidence thresholds are met. Dry-run by default; set write:'live' or
// OMNI_WRITE=live to persist to ~/.claude.
export function learn(s, a) {
  const hash = createHash('sha1')
    .update((a.scope || '') + '\x1f' + (a.type || '') + '\x1f' + (a.signature || ''))
    .digest('hex');
  const id = 'lesson:' + hash;

  // Read existing node to get server-truth evidence (populated by miner over real events)
  const existing = s.get('SELECT data FROM node WHERE id=?', id);
  let existingEv = null;
  let existingEnforce = false;
  if (existing) {
    try {
      const existingData = JSON.parse(existing.data);
      existingEv = existingData.evidence || null;
      existingEnforce = existingData.enforce === true;
    } catch { /* ignore */ }
  }

  // Use mined evidence verbatim — never increment occurrences per agent call
  const evidence = existingEv || {
    sessions: [],
    projects: (a.scope && a.scope !== 'GLOBAL' ? [a.scope] : []),
    occurrences: 1,
    models: [],
  };

  const lesson = {
    type: a.type,
    signature: a.signature,
    trigger: a.trigger || '',
    resolution: a.resolution || '',
    scope: a.scope,
    confidence: a.confidence || 'agent_confirmed',
    source: 'agent',
    evidence,
    // Preserve human-blessed enforce flag — agents cannot un-bless via omni_learn
    ...(existingEnforce ? { enforce: true } : {}),
  };

  // Upsert T0 db node (always)
  const now = new Date().toISOString();
  const label = (a.signature || '').length > 120 ? (a.signature || '').slice(0, 120) : (a.signature || '');
  const project = a.scope === 'GLOBAL' ? null : (a.scope || null);
  const stmt = s.db.prepare(`INSERT INTO node(id,kind,label,project,ts,data) VALUES(?,?,?,?,?,?)
    ON CONFLICT(id) DO UPDATE SET
      label=COALESCE(excluded.label, node.label),
      project=COALESCE(excluded.project, node.project),
      ts=CASE WHEN excluded.ts>node.ts THEN excluded.ts ELSE node.ts END,
      data=COALESCE(excluded.data, node.data)`);
  stmt.run(id, 'lesson', label, project, now, JSON.stringify(lesson));

  // Compute tier from server-truth evidence counts
  let tier;
  if (evidence.occurrences >= 5 && evidence.projects.length >= 2 && a.promote_skill) {
    tier = 'T2';
  } else if (evidence.occurrences >= 3 && evidence.sessions.length >= 2 && a.scope && a.scope !== 'GLOBAL') {
    tier = 'T1';
  } else {
    tier = 'T0';
  }

  const target = tier === 'T2'
    ? { kind: 'skill', name: a.promote_skill }
    : tier === 'T1'
      ? { kind: 'memory', slug: a.scope }
      : null;

  const mode = (a.write === 'live' || process.env.OMNI_WRITE === 'live') ? 'live' : 'dry';

  if (target) {
    const w = writeLesson({ target, lesson, mode });
    return { ok: true, id, tier, dbUpserted: true, write: w };
  }
  return { ok: true, id, tier: 'T0', dbUpserted: true, note: 'db-only; needs more evidence to promote to a file' };
}
