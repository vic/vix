#!/usr/bin/env node
'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const readline = require('readline');
const { randomUUID } = require('crypto');

const CACHE_DIR    = path.join(process.env.HOME || os.homedir(), '.cache', 'dw');
const DEFAULT_REPO = 'vic/haiku';
const DEFAULT_MODE = 'deep';
const API_BASE    = 'https://api.devin.ai/ada';
const ORIGIN      = 'https://deepwiki.com';
const UA          = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.116.0 Chrome/142.0.7444.265 Electron/39.8.7 Safari/537.36';
const POLL_MS     = 500;

function slugify(text) {
  return text.toLowerCase()
    .replace(/<[^>]+>/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .substring(0, 60);
}
function ts() { return new Date().toISOString(); }
function log(f, o) { fs.appendFileSync(f, JSON.stringify({ ...o, ts: ts() }) + '\n', 'utf8'); }
function dim(s) { return process.stdout.isTTY ? `\x1b[2m${s}\x1b[0m` : s; }
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
async function getQuery(queryId) { return httpGet(`${API_BASE}/query/${queryId}`); }

// Returns true if we wrote inline (chunk), false otherwise.
function renderEvent(ev) {
  if (!ev || typeof ev !== 'object') return false;
  switch (ev.type) {
    case 'module_call_id':
      // process.stdout.write(dim(`\n[thinking] ${ev.data && ev.data.module_call_id}\n`));
      return false;
    case 'loading_indexes':
      // process.stdout.write(dim(ev.data && ev.data.all_done ? '[indexes ready]\n' : '[loading indexes...]\n'));
      return false;
    case 'file_contents': {
      const f = Array.isArray(ev.data) ? (ev.data[1] || ev.data[0] || '?') : '?';
      process.stdout.write(dim(`   [file] ${f}\n`));
      return false;
    }
    case 'chunk':
      process.stdout.write(ev.data || '');
      return true;
    case 'done':
    case 'reference':
    case 'stats':
      return false;
    case 'tool_call_scanned_file':
      process.stdout.write(dim(`   [scanned] https://github.com/${ev.data.repo_name}/tree/main/${ev.data.file_path}\n`));
      return false;
    default:
      // process.stdout.write(dim(`[${ev.type}] ${JSON.stringify(ev.data)}\n`));
      return false;
  }
}

// Poll until the 'done' event appears in queries[queryIndex].response.
// This is exactly how the browser detects completion.
async function streamQuery(queryId, queryIndex, seenCounts, sessionFile) {
  let afterChunk = false;
  while (true) {
    let data;
    try { data = await getQuery(queryId); }
    catch (err) {
      if (afterChunk) process.stdout.write('\n');
      process.stderr.write(`[poll error] ${err.message}\n`);
      log(sessionFile, { type: 'poll_error', queryId, error: err.message });
      break;
    }

    const queries = Array.isArray(data.queries) ? data.queries : [];
    const q = queries[queryIndex];
    if (!q) break; // unexpected

    const events = Array.isArray(q.response) ? q.response : [];
    const seen = seenCounts[queryIndex] || 0;
    for (const ev of events.slice(seen)) {
      afterChunk = renderEvent(ev);
    }
    seenCounts[queryIndex] = events.length;
    log(sessionFile, { type: 'poll', queryId, queryIndex, state: q.state, eventCount: events.length });

    // 'done' event = browser's terminal signal
    if (events.some(e => e.type === 'done') || q.state === 'done' || q.state === 'failed' || q.state === 'error') {
      if (afterChunk) process.stdout.write('\n');
      log(sessionFile, { type: 'query_done', queryId, queryIndex, state: q.state });
      break;
    }

    await sleep(POLL_MS);
  }
}

function printUsage() {
  console.log('Usage: repl.js [--repo repo]... [--mode fast|deep] [--session id] [prompt words]');
  console.log(`Defaults: repo=${DEFAULT_REPO} mode=${DEFAULT_MODE}`);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const parsed = { repos: [], mode: DEFAULT_MODE, session: null, promptArgs: [], help: false };

  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '-h' || a === '--help') {
      parsed.help = true;
      break;
    }
    if (a === '--repo' || a === '-r') {
      if (args[i + 1]) { parsed.repos.push(args[++i]); continue; }
      throw new Error('Missing value for --repo');
    }
    if (a === '--session' || a === '-s') {
      if (args[i + 1]) { parsed.session = args[++i]; continue; }
      throw new Error('Missing value for --session');
    }
    if (a === '--mode' || a === '-m') {
      if (args[i + 1]) { parsed.mode = args[++i]; continue; }
      throw new Error('Missing value for --mode');
    }
    if (a.startsWith('--repo=')) { parsed.repos.push(a.slice(7)); continue; }
    if (a.startsWith('--session=')) { parsed.session = a.slice(10); continue; }
    if (a.startsWith('--mode=')) { parsed.mode = a.slice(7); continue; }
    if (a.startsWith('-')) {
      throw new Error(`Unknown option: ${a}`);
    }
    if (parsed.repos.length === 0) {
      parsed.repos.push(a);
      continue;
    }
    parsed.promptArgs.push(a);
  }

  if (parsed.repos.length === 0) parsed.repos = [DEFAULT_REPO];
  parsed.mode = parsed.mode === 'fast' ? 'fast' : 'deep';
  return parsed;
}

async function getQueryCount(queryId) {
  try {
    const data = await getQuery(queryId);
    const queries = Array.isArray(data.queries) ? data.queries : [];
    return queries.length;
  } catch (err) {
    return 0;
  }
}

async function warmRepos(repos) {
  for (const repo of repos) {
    await warmRepo(repo);
  }
}

async function runOneShot({ repos, mode, session, prompt }) {
  fs.mkdirSync(CACHE_DIR, { recursive: true });
  const sessionFile = path.join(CACHE_DIR, `${slugify(repos.join(','))}-${Date.now()}.jsonl`);
  log(sessionFile, { type: 'session_start', repos, mode, session });

  try {
    await warmRepos(repos);
    process.stdout.write(dim(`[warm] ${repos.join(', ')} ready\n\n`));
    log(sessionFile, { type: 'warm_ok', repos });
  } catch (err) {
    process.stderr.write(dim(`[warn] warm failed: ${err.message}\n\n`));
    log(sessionFile, { type: 'warm_fail', repos, error: err.message });
  }

  let queryId = null;
  let queryIndex = 0;
  let user_query;
  let isFirst = true;

  if (session) {
    const count = await getQueryCount(session);
    if (count > 0) {
      queryId = session;
      queryIndex = count;
      isFirst = false;
    } else {
      queryId = session;
      queryIndex = 0;
      isFirst = true;
    }
  } else {
    queryId = `${slugify(prompt)}_${randomUUID()}`;
    queryIndex = 0;
    isFirst = true;
  }

  const seenCounts = Array(queryIndex + 1).fill(0);

  user_query = isFirst
    ? `<relevant_context>This query was sent from the wiki page: ${repos[0]}.</relevant_context>${prompt}`
    : prompt;

  const payload = {
    mode,
    user_query,
    keywords: [],
    repo_names: repos,
    additional_context: '',
    query_id: queryId,
    use_notes: false,
    source: 'ada.deepwiki_public',
  };
  if (queryIndex === 0) payload.generate_summary = false;

  log(sessionFile, { type: 'query', queryId, queryIndex, question: prompt, session });
  await postQuery(payload);

  console.log();
  await streamQuery(queryId, queryIndex, seenCounts, sessionFile);
  console.log();
}

async function main() {
  let repos, mode, session, promptArgs;
  let parsed;
  try {
    parsed = parseArgs();
    ({ repos, mode, session, promptArgs } = parsed);
  } catch (err) {
    console.error(`Error: ${err.message}`);
    printUsage();
    process.exit(1);
  }

  if (parsed.help) {
    printUsage();
    return;
  }

  if (promptArgs.length === 0 && !process.stdin.isTTY) {
    printUsage();
    process.exit(1);
  }

  const prompt = promptArgs.join(' ');
  if (prompt) {
    await runOneShot({ repos, mode, session, prompt });
    return;
  }

  fs.mkdirSync(CACHE_DIR, { recursive: true });
  const sessionFile = path.join(CACHE_DIR, `${slugify(repos.join(','))}-${Date.now()}.jsonl`);
  log(sessionFile, { type: 'session_start', repos, mode, session });

  console.log(`\nDeepWiki REPL  repos=${repos.join(', ')}  mode=${mode}`);
  console.log(`log: ${sessionFile}`);
  console.log('Commands: reset | quit\n');

  try {
    await warmRepos(repos);
    process.stdout.write(dim(`[warm] ${repos.join(', ')} ready\n\n`));
    log(sessionFile, { type: 'warm_ok', repos });
  } catch (err) {
    process.stderr.write(dim(`[warn] warm failed: ${err.message}\n\n`));
    log(sessionFile, { type: 'warm_fail', repos, error: err.message });
  }

  let queryId = null;
  let queryIndex = -1;
  let seenCounts = [];

  if (session) {
    const count = await getQueryCount(session);
    if (count > 0) {
      queryId = session;
      queryIndex = count - 1;
      seenCounts = Array(count + 1).fill(0);
      process.stdout.write(dim(`[session] continuing existing thread ${session}\n\n`));
      log(sessionFile, { type: 'session_continue', session, existingCount: count });
    }
  }

  const promptLabel = repos.length === 1 ? repos[0] : 'repos';
  const showPrompt = () => { if (process.stdin.isTTY) process.stdout.write(`${promptLabel}> `); };
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: false });
  rl.on('SIGINT', () => { console.log('\nbye'); process.exit(0); });
  showPrompt();

  for await (const rawLine of rl) {
    const q = rawLine.trim();
    if (!q) { showPrompt(); continue; }

    if (q === 'quit' || q === 'exit') break;

    if (q === 'reset') {
      queryId = null; queryIndex = -1; seenCounts = [];
      process.stdout.write(dim('[reset] new thread\n\n'));
      log(sessionFile, { type: 'reset' });
      showPrompt();
      continue;
    }

    let user_query, thisQueryId;
    if (queryId === null) {
      thisQueryId = `${slugify(q)}_${randomUUID()}`;
      queryId = thisQueryId;
      queryIndex = 0;
      seenCounts = [0];
      user_query = `<relevant_context>This query was sent from the wiki page: ${repos[0]}.</relevant_context>${q}`;
    } else {
      thisQueryId = queryId;
      queryIndex += 1;
      seenCounts[queryIndex] = 0;
      user_query = q;
    }

    const payload = {
      mode,
      user_query,
      keywords: [],
      repo_names: repos,
      additional_context: '',
      query_id: thisQueryId,
      use_notes: false,
      source: 'ada.deepwiki_public',
    };
    if (queryIndex === 0) payload.generate_summary = false;

    log(sessionFile, { type: 'query', queryId: thisQueryId, queryIndex, question: q });

    try { await postQuery(payload); }
    catch (err) {
      process.stderr.write(`[error] ${err.message}\n`);
      log(sessionFile, { type: 'post_error', queryId: thisQueryId, error: err.message });
      showPrompt();
      continue;
    }

    console.log();
    await streamQuery(thisQueryId, queryIndex, seenCounts, sessionFile);
    console.log();
    showPrompt();
  }

  rl.close();
  log(sessionFile, { type: 'session_end' });
}

main().catch(err => { console.error('Fatal:', err); process.exit(1); });
