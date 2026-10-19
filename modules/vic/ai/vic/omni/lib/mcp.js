// mcp.js — zero-dep MCP stdio server (newline-delimited JSON-RPC 2.0).
// Exposes the omni knowledge graph to agents: cross-project visibility,
// token-routing telemetry, full-text recall. Logs -> stderr, protocol -> stdout.
import { createInterface } from 'node:readline';
import { Store } from './store.js';
import * as Q from './query.js';
import { OMNI_INSTRUCTIONS } from './instructions.js';
import * as Check from './check.js';

const TOOLS = [
  { name: 'omni_status',
    description: 'Global knowledge-graph overview: node/edge/event counts, total token burn (in/out/cache), and top projects ranked by burn. Use first to orient across ALL of vic\'s projects.',
    inputSchema: { type: 'object', properties: {} },
    handler: (s) => Q.status(s) },
  { name: 'omni_search',
    description: 'Full-text search across EVERY session transcript, prompt, title, and file in all projects (or one). Use to recall "where did we discuss X", find prior work on a concept, locate a decision. Returns ranked snippets with project + ref.',
    inputSchema: { type: 'object', properties: { q: { type: 'string', description: 'search terms' }, project: { type: 'string', description: 'optional project name to scope' } }, required: ['q'] },
    handler: (s, a) => Q.search(s, a.q, { project: a.project || null, limit: a.limit || 25 }) },
  { name: 'omni_project',
    description: 'Summary of ONE project: what was being built (recent session titles), total token burn, top tools/skills/files, and per-model dispatch burn. Use to onboard onto a project or answer "what is the state of X".',
    inputSchema: { type: 'object', properties: { name: { type: 'string', description: 'project name e.g. dnet, dnx2, rev' } }, required: ['name'] },
    handler: (s, a) => Q.projectSummary(s, a.name) },
  { name: 'omni_sessions',
    description: 'Recent sessions (optionally for one project) with title, model, token burn, and event count. Use to see "what has been happening lately".',
    inputSchema: { type: 'object', properties: { project: { type: 'string' }, limit: { type: 'number' } } },
    handler: (s, a) => Q.sessions(s, { project: a.project || null, limit: a.limit || 25 }) },
  { name: 'omni_dispatches',
    description: 'Per-dispatched-agent telemetry: model used, output/input tokens, tool count — ranked by burn. Use to audit token routing (is opus being used where haiku/sonnet would do?) and find expensive agent runs.',
    inputSchema: { type: 'object', properties: { project: { type: 'string' }, limit: { type: 'number' } } },
    handler: (s, a) => Q.dispatches(s, { project: a.project || null, limit: a.limit || 40 }) },
  { name: 'omni_models',
    description: 'Token burn broken down by model across all events: events, input/output tokens, distinct dispatch runs. The routing-policy ground truth.',
    inputSchema: { type: 'object', properties: {} },
    handler: (s) => Q.modelBurn(s) },
  { name: 'omni_concept',
    description: 'Where a concept/acronym/term appears across all projects (occurrence count + grouped snippets by project). Use to navigate cross-project knowledge and resolve "what is X".',
    inputSchema: { type: 'object', properties: { term: { type: 'string' } }, required: ['term'] },
    handler: (s, a) => Q.concept(s, a.term) },
  { name: 'omni_files',
    description: 'Most-touched files (hotspots), globally or per project. Use to find where the action is in a codebase.',
    inputSchema: { type: 'object', properties: { project: { type: 'string' }, limit: { type: 'number' } } },
    handler: (s, a) => Q.fileHotspots(s, { project: a.project || null, limit: a.limit || 20 }) },
  { name: 'omni_acronyms',
    description: 'Glossary of acronyms/terms extracted from project vic/*.md docs (TERM = definition). Use to resolve unfamiliar acronyms BEFORE asking vic. Optionally scope to one project.',
    inputSchema: { type: 'object', properties: { project: { type: 'string' } } },
    handler: (s, a) => Q.acronyms(s, { project: a.project || null }) },
  { name: 'omni_remaining',
    description: 'What REMAINS to do in a project: OPEN decisions/items parsed from its vic/ track docs (LAW/OPEN/DEAD sections). Use to answer "what is left / current state of X".',
    inputSchema: { type: 'object', properties: { project: { type: 'string' } }, required: ['project'] },
    handler: (s, a) => Q.remaining(s, a.project) },
  { name: 'omni_errors',
    description: 'Tool-error summary: sessions and projects ranked by total tool_result errors (is_error:true). Returns total_errors, error_rate (errors/events), per-session and per-project breakdowns. Use to answer "which sessions/projects thrash most on tool failures".',
    inputSchema: { type: 'object', properties: { project: { type: 'string', description: 'optional project name to scope' }, limit: { type: 'number', description: 'max rows per list (default 20)' } } },
    handler: (s, a) => Q.errors(s, { project: a.project || null, limit: a.limit || 20 }) },
  { name: 'omni_health',
    description: 'Workflow-health audit: model token-routing breakdown (runs, out/run, %burn), runaway-dispatch count+list, cache reuse ratio, Read:codegraph adoption, and concrete recommendations. Use to optimize token spend and catch under-partitioned dispatches.',
    inputSchema: { type: 'object', properties: {} },
    handler: (s) => Q.health(s) },
  { name: 'omni_recall',
    description: 'Recall lessons mined/captured from past sessions: recurring error->resolution, dead-ends, and skill x model $$ efficacy (the cheapest proven path for a task class). Call BEFORE re-deriving anything cross-session. Project lessons stay in-project; one-off lessons flagged tentative.',
    inputSchema: { type: 'object', properties: { scope: { type: 'string' }, type: { type: 'string' }, query: { type: 'string' }, include_global: { type: 'boolean' }, limit: { type: 'number' } } },
    handler: (s, a) => Q.recall(s, { scope: a.scope || null, type: a.type || null, query: a.query || null, include_global: a.include_global !== false, limit: a.limit || 25 }) },
  { name: 'omni_learn',
    description: 'Record a verified, durable, non-obvious lesson. Always upserts to the omni graph (db); promotes to a memory file (recurrence>=3, >=2 sessions, project scope) or skill body (>=5, >=2 projects, promote_skill) automatically. Dry-run by default (returns the diff) — set write:"live" or OMNI_WRITE=live to persist. Never edits frontmatter. Capture only non-obvious verified insights; bloat poisons recall.',
    inputSchema: { type: 'object', required: ['type', 'signature', 'scope'], properties: { type: { type: 'string', enum: ['error_signature', 'skill_efficacy', 'error_fix', 'dead_end'] }, signature: { type: 'string' }, trigger: { type: 'string' }, resolution: { type: 'string' }, scope: { type: 'string' }, confidence: { type: 'string', enum: ['observed', 'agent_confirmed'] }, related: { type: 'array', items: { type: 'string' } }, promote_skill: { type: 'string' }, write: { type: 'string', enum: ['dry', 'live'] } } },
    handler: (s, a) => Q.learn(s, a) },
  { name: 'omni_check',
    description: 'Consult learned lessons for a PROSPECTIVE action and return an enforcement verdict {decision: allow|warn|deny, reason, lesson_ref}. DENY only for human-blessed (enforce) lessons on an exact action match in scope; everything else allow/warn. Fails open. Agents: call before a risky/irreversible action to see if it is a known dead-end.',
    inputSchema: { type: 'object', required: ['tool_name', 'action'], properties: { tool_name: { type: 'string' }, action: { type: 'string' }, command: { type: 'string' }, file: { type: 'string' }, scope: { type: 'string' } } },
    handler: (s, a) => Check.check(s, { tool_name: a.tool_name, command: a.command || a.action, file: a.file, scope: a.scope || null }) },
];

function send(msg) { process.stdout.write(JSON.stringify(msg) + '\n'); }
const err = (id, code, message) => send({ jsonrpc: '2.0', id, error: { code, message } });

function handle(line, s) {
  let req;
  try { req = JSON.parse(line); } catch { return; }
  const { id, method, params } = req || {};
  if (method === 'initialize') return send({ jsonrpc: '2.0', id, result: { protocolVersion: '2024-11-05', capabilities: { tools: {} }, serverInfo: { name: 'omni', version: '0.1.0' }, instructions: OMNI_INSTRUCTIONS } });
  if (typeof method === 'string' && method.startsWith('notifications/')) return; // no reply
  if (method === 'ping') return send({ jsonrpc: '2.0', id, result: {} });
  if (method === 'tools/list') return send({ jsonrpc: '2.0', id, result: { tools: TOOLS.map(({ name, description, inputSchema }) => ({ name, description, inputSchema })) } });
  if (method === 'tools/call') {
    const t = TOOLS.find((x) => x.name === params?.name);
    if (!t) return err(id, -32602, 'unknown tool: ' + params?.name);
    try {
      const data = t.handler(s, params.arguments || {});
      const text = typeof data === 'string' ? data : JSON.stringify(data, null, 2);
      return send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text }] } });
    } catch (e) {
      return send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'error: ' + e.message }], isError: true } });
    }
  }
  if (id !== undefined && id !== null) err(id, -32601, 'method not found: ' + method);
}

export async function main({ DB }) {
  const s = new Store(DB);
  process.stderr.write('omni mcp ready (db ' + DB + ')\n');
  const rl = createInterface({ input: process.stdin, terminal: false });
  rl.on('line', (line) => { if (line.trim()) handle(line, s); });
  rl.on('close', () => { s.close(); process.exit(0); });
}
