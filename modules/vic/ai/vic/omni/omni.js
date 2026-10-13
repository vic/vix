#!/usr/bin/env node
// omni CLI — ingest | status | serve | watch | mcp
import { Store } from './lib/store.js';
import { ingestAll } from './lib/ingest.js';
import { ingestDocs } from './lib/extract.js';
import * as Q from './lib/query.js';
import * as Check from './lib/check.js';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { execSync } from 'node:child_process';
import { mkdirSync, copyFileSync } from 'node:fs';

const _require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const REPODIR = path.dirname(__filename);

const HOME = process.env.HOME;
const DB = process.env.OMNI_DB || HOME + '/.claude/omni.db';
const ROOT = process.env.OMNI_ROOT || HOME + '/.claude/projects';
const cmd = process.argv[2] || 'status';

function fmt(n) { return Number(n).toLocaleString('en-US'); }

function statusReport(s) {
  const counts = s.all("SELECT kind, count(*) c FROM node GROUP BY kind ORDER BY c DESC");
  const ev = s.get('SELECT count(*) c FROM event').c;
  const edges = s.get('SELECT count(*) c FROM edge').c;
  const files = s.get('SELECT count(*) c FROM ingest_state').c;
  const burn = s.get('SELECT sum(in_tok) i, sum(out_tok) o, sum(cache_r) cr, sum(cache_w) cw FROM event');
  const topProj = s.all(`SELECT project, sum(in_tok+out_tok) t, count(*) e FROM event
     WHERE project IS NOT NULL GROUP BY project ORDER BY t DESC LIMIT 8`);
  console.log('OMNI status — db', DB);
  console.log('  events', fmt(ev), '| edges', fmt(edges), '| files', fmt(files));
  console.log('  nodes:', counts.map((r) => `${r.kind}=${r.c}`).join(' '));
  console.log('  tokens: in', fmt(burn.i || 0), 'out', fmt(burn.o || 0), 'cache_r', fmt(burn.cr || 0), 'cache_w', fmt(burn.cw || 0));
  console.log('  top projects by burn:');
  for (const p of topProj) console.log(`    ${fmt(p.t)}  (${p.e} ev)  ${p.project}`);
}

if (cmd === 'ingest') {
  const s = new Store(DB);
  const t0 = Date.now();
  const out = ingestAll(s, ROOT);
  let files = 0, touched = 0, processed = 0;
  for (const k of Object.keys(out)) { files += out[k].files; touched += out[k].touched; processed += out[k].processed; }
  console.log(`ingested ${processed} new events from ${touched}/${files} files (${Object.keys(out).length} projects) in ${Date.now() - t0}ms`);
  const docs = ingestDocs(s);
  console.log(`docs: ${docs.acronyms} acronyms + ${docs.decisions} decisions from ${docs.files} vic/*.md`);
  const nidx = Q.buildSearchIndex(s);
  console.log('search index:', nidx, 'docs');
  try { const nl = Q.materializeLessons(s); console.log('lessons:', nl, 'materialized'); } catch (e) { console.error('lessons (non-fatal):', e.message); }
  try { const nk = await Check.writeDenyKeyCache(s); console.log('deny-keys:', nk, 'written'); } catch (e) { console.error('deny-keys (non-fatal):', e.message); }
  statusReport(s);
  s.close();
} else if (cmd === 'report' || cmd === 'health') {
  const s = new Store(DB);
  const h = Q.health(s);
  console.log('OMNI workflow health\n');
  console.log('routing (model | runs | out tok | out/run | %burn):');
  for (const r of h.routing) console.log(`  ${r.model.padEnd(26)} ${String(r.runs).padStart(5)} ${fmt(r.out_tok).padStart(12)} ${fmt(r.out_per_run).padStart(9)} ${String(r.share_pct).padStart(5)}%`);
  console.log(`\ncache reuse: ${h.cache_read_input_ratio}x   runaway dispatches: ${h.runaway_count}`);
  console.log(`tool adoption: Read=${fmt(h.tool_adoption.Read)} codegraph=${fmt(h.tool_adoption.codegraph)} (ratio ${h.tool_adoption.ratio}:1)`);
  console.log(`sessions: ${h.sessions} (${h.unlabeled} unlabeled)`);
  console.log('\nrecommendations:');
  for (const r of h.recommendations) console.log('  • ' + r);
  s.close();
} else if (cmd === 'index') {
  const s = new Store(DB);
  console.log('search index:', Q.buildSearchIndex(s), 'docs');
  try { console.log('lessons:', Q.materializeLessons(s), 'materialized'); } catch (e) { console.error('lessons (non-fatal):', e.message); }
  try { const nk = await Check.writeDenyKeyCache(s); console.log('deny-keys:', nk, 'written'); } catch (e) { console.error('deny-keys (non-fatal):', e.message); }
  s.close();
} else if (cmd === 'status') {
  const s = new Store(DB);
  statusReport(s);
  s.close();
} else if (['search', 'project', 'sessions', 'dispatches', 'models', 'concept', 'acronyms', 'remaining'].includes(cmd)) {
  const s = new Store(DB);
  const arg = process.argv[3];
  const r = cmd === 'search' ? Q.search(s, arg, { limit: 20 })
    : cmd === 'project' ? Q.projectSummary(s, arg)
    : cmd === 'sessions' ? Q.sessions(s, { project: arg, limit: 25 })
    : cmd === 'dispatches' ? Q.dispatches(s, { project: arg, limit: 30 })
    : cmd === 'concept' ? Q.concept(s, arg)
    : cmd === 'acronyms' ? Q.acronyms(s, { project: arg })
    : cmd === 'remaining' ? Q.remaining(s, arg)
    : Q.modelBurn(s);
  console.log(JSON.stringify(r, null, 2));
  s.close();
} else if (cmd === 'serve') {
  const serve = await import('./lib/serve.js');
  const { broadcast } = await serve.main({ DB, ROOT, argv: process.argv.slice(3) });
  const { startWatcher } = await import('./lib/watch.js');
  startWatcher({ DB, ROOT, broadcast, log: (m) => console.log('[watch]', m) });
  console.log('[watch] live auto-ingest active');
} else if (cmd === 'check') {
  const s = new Store(DB);
  if (process.argv.includes('--hook')) {
    try {
      const raw = await new Promise((res, rej) => {
        let buf = '';
        process.stdin.setEncoding('utf8');
        process.stdin.on('data', (d) => { buf += d; });
        process.stdin.on('end', () => res(buf));
        process.stdin.on('error', rej);
      });
      const j = JSON.parse(raw);
      const tool_name = j.tool_name;
      const command = j.tool_input?.command;
      const file = j.tool_input?.file_path;
      const scope = j.cwd || null;
      const v = Check.check(s, { tool_name, command, file, scope });
      process.stdout.write(JSON.stringify(Check.emitHookJSON(v)));
    } catch {
      process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'allow' } }));
    }
    s.close();
    process.exit(0);
  } else {
    const action = process.argv[3] || '';
    const v = Check.check(s, { tool_name: 'Bash', command: action, scope: null });
    console.log(JSON.stringify(v));
    s.close();
  }
} else if (cmd === 'bless') {
  const id = process.argv[3];
  if (!id) { console.error('usage: omni bless <lesson-id>'); process.exit(1); }
  const s = new Store(DB);
  const row = s.get('SELECT data FROM node WHERE id=?', id);
  if (!row) { console.error('lesson not found:', id); s.close(); process.exit(1); }
  let data;
  try { data = JSON.parse(row.data); } catch { console.error('corrupt lesson data for:', id); s.close(); process.exit(1); }
  data.enforce = true;
  data.confidence = 'agent_confirmed';
  s.db.prepare('UPDATE node SET data=? WHERE id=?').run(JSON.stringify(data), id);
  const n = await Check.writeDenyKeyCache(s);
  console.log('blessed ' + id + ' (enforce=true); deny-keys refreshed (' + n + ')');
  s.close();
} else if (cmd === 'unbless') {
  const id = process.argv[3];
  if (!id) { console.error('usage: omni unbless <lesson-id>'); process.exit(1); }
  const s = new Store(DB);
  const row = s.get('SELECT data FROM node WHERE id=?', id);
  if (!row) { console.error('lesson not found:', id); s.close(); process.exit(1); }
  let data;
  try { data = JSON.parse(row.data); } catch { console.error('corrupt lesson data for:', id); s.close(); process.exit(1); }
  data.enforce = false;
  s.db.prepare('UPDATE node SET data=? WHERE id=?').run(JSON.stringify(data), id);
  const n = await Check.writeDenyKeyCache(s);
  console.log('unblessed ' + id + ' (enforce=false); deny-keys refreshed (' + n + ')');
  s.close();
} else if (cmd === 'hook') {
  const sub = process.argv[3];
  const hooksSrc = path.join(REPODIR, 'hooks', 'omni-pretool.sh');
  const hooksDst = path.join(HOME, '.claude', 'hooks');
  const installer = path.join(REPODIR, 'hooks', 'omni-hook-install.sh');
  if (sub === 'install') {
    mkdirSync(hooksDst, { recursive: true });
    copyFileSync(hooksSrc, path.join(hooksDst, 'omni-pretool.sh'));
    execSync('bash ' + installer + ' --install', { stdio: 'inherit' });
  } else if (sub === 'uninstall') {
    execSync('bash ' + installer + ' --uninstall', { stdio: 'inherit' });
  } else {
    console.error('usage: omni hook install|uninstall');
    process.exit(1);
  }
} else if (cmd === 'watch' || cmd === 'mcp') {
  const mod = await import('./lib/' + cmd + '.js').catch((e) => { console.error(cmd, 'not built yet:', e.message); process.exit(2); });
  await mod.main({ DB, ROOT, argv: process.argv.slice(3) });
} else {
  console.error('usage: omni ingest|index|status|search <q>|project <name>|sessions [proj]|dispatches [proj]|models|concept <t>|check|bless <id>|unbless <id>|hook install|uninstall|serve|watch|mcp');
  process.exit(1);
}
