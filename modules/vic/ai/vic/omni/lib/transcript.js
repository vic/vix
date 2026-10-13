// transcript.js — pure parser: Claude Code .jsonl line -> typed Event union.
// Zero deps. No throw on bad input: corrupt/truncated line -> {ok:false}.
// Closed type set = correct-by-construction (unknown type still parsed but flagged).

export const PARSER_VERSION = 1;

export const EVENT_TYPES = Object.freeze([
  'assistant', 'user', 'attachment', 'permission-mode', 'mode',
  'last-prompt', 'queue-operation', 'file-history-snapshot', 'ai-title', 'system',
]);
const KNOWN = new Set(EVENT_TYPES);

// usage block (assistant) -> normalized token counts (0 when absent).
function usageOf(u) {
  if (!u || typeof u !== 'object') return null;
  return {
    in: u.input_tokens | 0,
    out: u.output_tokens | 0,
    cache_r: u.cache_read_input_tokens | 0,
    cache_w: u.cache_creation_input_tokens | 0,
  };
}

// message.content may be string | array | undefined -> always array of blocks.
function blocksOf(content) {
  if (content == null) return [];
  if (typeof content === 'string') return [{ type: 'text', text: content }];
  if (Array.isArray(content)) return content;
  return [];
}

function textOf(blocks) {
  let s = '';
  for (const b of blocks) {
    if (b && b.type === 'text' && typeof b.text === 'string') s += (s ? '\n' : '') + b.text;
  }
  return s;
}

function toolsOf(blocks) {
  const out = [];
  for (const b of blocks) {
    if (b && b.type === 'tool_use') out.push({ name: b.name || '', input: b.input ?? null, id: b.id });
  }
  return out;
}

// Count content blocks that are failed tool_result responses.
function errorsOf(blocks) {
  let n = 0;
  for (const b of blocks) {
    if (b && b.type === 'tool_result' && b.is_error === true) n++;
  }
  return n;
}

// Extract text from tool_result blocks (string OR array-of-{type:'text'} content).
// Error blocks are prefixed with 'ERROR: ' for miner legibility.
function toolResultText(blocks) {
  let s = '';
  for (const b of blocks) {
    if (!b || b.type !== 'tool_result') continue;
    let part = '';
    if (typeof b.content === 'string') {
      part = b.content;
    } else if (Array.isArray(b.content)) {
      part = b.content.filter((c) => c && c.type === 'text' && typeof c.text === 'string').map((c) => c.text).join('\n');
    }
    if (!part) continue;
    const labeled = b.is_error === true ? 'ERROR: ' + part : part;
    s += (s ? '\n' : '') + labeled;
  }
  return s;
}

// Normalize a parsed object into the Event record. Pure, total.
function normalize(o) {
  const msg = o.message && typeof o.message === 'object' ? o.message : {};
  const blocks = blocksOf(msg.content);
  const ev = {
    ok: true,
    etype: o.type,
    known: KNOWN.has(o.type),
    uuid: o.uuid ?? null,
    parent: o.parentUuid ?? null,
    session: o.sessionId ?? null,
    ts: o.timestamp ?? null,
    cwd: o.cwd ?? null,
    branch: o.gitBranch ?? null,
    version: o.version ?? null,
    userType: o.userType ?? null,
    sidechain: !!o.isSidechain,
    role: msg.role ?? null,
    model: msg.model ?? null,
    usage: usageOf(msg.usage),
    skill: o.attributionSkill ?? null,
    text: [textOf(blocks), toolResultText(blocks)].filter(Boolean).join('\n'),
    tools: toolsOf(blocks),
    errors: errorsOf(blocks),
    title: o.type === 'ai-title' ? (o.aiTitle ?? o.title ?? o.content ?? null) : null,
    raw: o,
  };
  // last-prompt / user prompt text surfacing
  if (o.type === 'last-prompt') ev.prompt = o.prompt ?? o.content ?? ev.text ?? null;
  return ev;
}

// Parse ONE line -> Event | null(blank) | {ok:false} on bad input. Never throws.
export function parseLine(line) {
  if (line == null) return null;
  const t = line.trim();
  if (!t) return null;
  let o;
  try { o = JSON.parse(t); }
  catch { return { ok: false, error: 'json', line: t.slice(0, 200) }; }
  if (typeof o.type !== 'string') return { ok: false, error: 'no-type', line: t.slice(0, 200) };
  return normalize(o);
}

// Parse whole transcript text -> generator of Events (skips blanks).
export function* parseText(text) {
  if (typeof text !== 'string') return;
  for (const line of text.split('\n')) {
    const ev = parseLine(line);
    if (ev) yield ev;
  }
}
