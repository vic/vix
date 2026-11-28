#!/usr/bin/env node
'use strict';

// DeepWiki MCP server — STDIO transport, JSON-RPC 2.0
// Exposes one tool: dw_ask
// Use session_id from the response to continue a thread (same query_id as repl.js)

const fs = require('fs');
const os = require('os');
const path = require('path');
const { randomUUID } = require('crypto');

const CACHE_DIR = path.join(process.env.HOME || os.homedir(), '.cache', 'dw');

function ts() { return new Date().toISOString(); }
function log(sessionFile, o) { fs.appendFileSync(sessionFile, JSON.stringify({ ...o, ts: ts() }) + '\n', 'utf8'); }

// ── DeepWiki API (identical to repl.js) ────────────────────────────────────

const API_BASE = 'https://api.devin.ai/ada';
const ORIGIN   = 'https://deepwiki.com';
const UA       = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.116.0 Chrome/142.0.7444.265 Electron/39.8.7 Safari/537.36';
const POLL_MS  = 500;

function slugify(text) {
  return text.toLowerCase()
    .replace(/<[^>]+>/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .substring(0, 60);
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

function baseHeaders(extra = {}) {
  return { origin: ORIGIN, referer: ORIGIN + '/', 'user-agent': UA, ...extra };
}

async function httpPost(url, body) {
  const opts = {
    method: 'POST',
    headers: baseHeaders(body !== undefined ? { 'content-type': 'application/json' } : {}),
  };
  if (body !== undefined) opts.body = JSON.stringify(body);
  const res = await fetch(url, opts);
  const text = await res.text();
  if (!res.ok) throw new Error(`HTTP ${res.status} POST ${url}: ${text.substring(0, 200)}`);
  return text ? JSON.parse(text) : null;
}

async function httpGet(url) {
  const res = await fetch(url, { method: 'GET', headers: baseHeaders({ accept: 'application/json' }) });
  const text = await res.text();
  if (!res.ok) throw new Error(`HTTP ${res.status} GET ${url}: ${text.substring(0, 200)}`);
  return JSON.parse(text);
}

async function warmRepo(repo) {
  await httpPost(`${API_BASE}/warm_public_repo?repo_name=${encodeURIComponent(repo)}`, undefined);
}
async function postQuery(payload) { return httpPost(`${API_BASE}/query`, payload); }
async function getQuery(queryId)  { return httpGet(`${API_BASE}/query/${queryId}`); }

// Poll until done event; calls onChunk with each text fragment as it arrives.
async function collectQuery(queryId, queryIndex, seenCounts, onChunk) {
  const parts = [];
  while (true) {
    const data = await getQuery(queryId);
    const queries = Array.isArray(data.queries) ? data.queries : [];
    const q = queries[queryIndex];
    if (!q) throw new Error(`queryIndex ${queryIndex} missing in response`);

    const events = Array.isArray(q.response) ? q.response : [];
    const seen = seenCounts[queryIndex] || 0;
    for (const ev of events.slice(seen)) {
      if (ev && ev.type === 'chunk' && ev.data) {
        parts.push(ev.data);
        if (onChunk) onChunk(ev.data);
      }
    }
    seenCounts[queryIndex] = events.length;

    if (events.some(e => e.type === 'done') || q.state === 'done' || q.state === 'failed' || q.state === 'error') {
      break;
    }
    await sleep(POLL_MS);
  }
  return parts.join('');
}

// ── Session store ───────────────────────────────────────────────────────────
// session_id → { repo, mode, queryId, queryIndex, seenCounts }
const sessions = new Map();

// ── MCP wire protocol ───────────────────────────────────────────────────────

function send(obj) {
  process.stdout.write(JSON.stringify(obj) + '\n');
}

function respond(id, result) {
  send({ jsonrpc: '2.0', id, result });
}

function respondError(id, code, message) {
  send({ jsonrpc: '2.0', id, error: { code, message } });
}

function notify(method, params) {
  send({ jsonrpc: '2.0', method, params });
}

// ── Tool definition ─────────────────────────────────────────────────────────

const TOOL = {
  name: 'dw_ask',
  description:
    'Ask a question about any public GitHub repository using DeepWiki. ' +
    'Returns a detailed answer grounded in the repository\'s source code. ' +
    'Pass the returned session_id back as an argument to ask follow-up questions ' +
    'within the same context thread (same query_id the browser uses).',
  inputSchema: {
    type: 'object',
    properties: {
      repo: {
        type: 'string',
        description: 'GitHub repository in "owner/name" format, e.g. "microsoft/vscode".',
      },
      question: {
        type: 'string',
        description: 'The question to ask about the repository.',
      },
      session_id: {
        type: 'string',
        description:
          'Optional. The session_id returned by a previous deepwiki_ask call. ' +
          'Supply this to continue the conversation in the same context thread.',
      },
      mode: {
        type: 'string',
        enum: ['fast', 'deep'],
        description: 'Query mode. "fast" for quick answers; "deep" (default) for more thorough analysis.',
      },
    },
    required: ['repo', 'question'],
  },
};

// ── Tool handler ────────────────────────────────────────────────────────────

async function runDeepwikiAsk(args, progressToken) {
  const { repo, question, session_id, mode: modeArg } = args;
  if (!repo   || typeof repo   !== 'string') throw new Error('"repo" must be a non-empty string');
  if (!question || typeof question !== 'string') throw new Error('"question" must be a non-empty string');
  const mode = modeArg === 'fast' ? 'fast' : 'deep';

  let queryId, queryIndex, seenCounts, isFirst;

  let sessionFile;
  if (session_id && sessions.has(session_id)) {
    const s = sessions.get(session_id);
    queryId    = s.queryId;
    queryIndex = s.queryIndex + 1;
    seenCounts = s.seenCounts;
    seenCounts[queryIndex] = 0;
    sessionFile = s.sessionFile;
    isFirst = false;
  } else {
    queryId    = `${slugify(question)}_${randomUUID()}`;
    queryIndex = 0;
    seenCounts = [0];
    isFirst    = true;
    fs.mkdirSync(CACHE_DIR, { recursive: true });
    sessionFile = path.join(CACHE_DIR, `${slugify(repo)}-${Date.now()}.jsonl`);
    log(sessionFile, { type: 'session_start', repo, mode });
    // warm is best-effort; don't fail on error
    try { await warmRepo(repo); log(sessionFile, { type: 'warm_ok', repo }); } catch (err) { log(sessionFile, { type: 'warm_fail', repo, error: err.message }); }
  }

  const user_query = isFirst
    ? `<relevant_context>This query was sent from the wiki page: ${repo}.</relevant_context>${question}`
    : question;

  const payload = {
    mode,
    user_query,
    keywords:           [],
    repo_names:         [repo],
    additional_context: '',
    query_id:           queryId,
    use_notes:          false,
    source:             'ada.deepwiki_public',
  };
  if (isFirst) payload.generate_summary = false;

  log(sessionFile, { type: 'query', queryId, queryIndex, question });
  await postQuery(payload);

  // Stream chunks as progress notifications (agents that support it will see live output)
  let charsEmitted = 0;
  const answer = await collectQuery(queryId, queryIndex, seenCounts, (chunk) => {
    charsEmitted += chunk.length;
    log(sessionFile, { type: 'chunk', queryId, queryIndex, data: chunk });
    if (progressToken !== undefined && progressToken !== null) {
      notify('notifications/progress', {
        progressToken,
        progress: charsEmitted,
        message: chunk,
      });
    }
  });

  log(sessionFile, { type: 'query_done', queryId, queryIndex });

  // Update / register session
  const new_session_id = session_id && sessions.has(session_id) ? session_id : queryId;
  sessions.set(new_session_id, { repo, mode, queryId, queryIndex, seenCounts, sessionFile });

  return answer + `\n\n---\n*session_id: ${new_session_id}*`;
}

// ── Request router ──────────────────────────────────────────────────────────

async function handleMessage(msg) {
  if (!msg || msg.jsonrpc !== '2.0') return;
  const { id, method, params } = msg;
  const isNotification = id === undefined || id === null;

  switch (method) {

    case 'initialize':
      respond(id, {
        protocolVersion: '2024-11-05',
        capabilities: { tools: {} },
        serverInfo: { name: 'dw-mcp', version: '1.0.0' },
      });
      break;

    case 'notifications/initialized':
      break; // client notification, no response

    case 'ping':
      if (!isNotification) respond(id, {});
      break;

    case 'tools/list':
      respond(id, { tools: [TOOL] });
      break;

    case 'tools/call': {
      const name = params && params.name;
      const toolArgs = (params && params.arguments) || {};
      const progressToken = params && params._meta && params._meta.progressToken;

      if (name !== 'dw_ask') {
        respondError(id, -32601, `Unknown tool: ${name}`);
        break;
      }

      try {
        const text = await runDeepwikiAsk(toolArgs, progressToken);
        respond(id, { content: [{ type: 'text', text }] });
      } catch (err) {
        respond(id, { content: [{ type: 'text', text: `Error: ${err.message}` }], isError: true });
      }
      break;
    }

    default:
      if (!isNotification) respondError(id, -32601, `Method not found: ${method}`);
  }
}

// ── STDIO message loop ──────────────────────────────────────────────────────

process.stderr.write('[dw-mcp] ready\n');

let buf = '';
let pending = 0;
let stdinEnded = false;

process.stdin.setEncoding('utf8');

process.stdin.on('data', (chunk) => {
  buf += chunk;
  let nl;
  while ((nl = buf.indexOf('\n')) !== -1) {
    const line = buf.slice(0, nl).trim();
    buf = buf.slice(nl + 1);
    if (!line) continue;
    let msg;
    try { msg = JSON.parse(line); } catch { continue; }
    pending++;
    handleMessage(msg)
      .catch(err => process.stderr.write(`[error] ${err.message}\n`))
      .finally(() => { pending--; if (stdinEnded && pending === 0) process.exit(0); });
  }
});

process.stdin.on('end', () => {
  stdinEnded = true;
  if (pending === 0) process.exit(0);
});
