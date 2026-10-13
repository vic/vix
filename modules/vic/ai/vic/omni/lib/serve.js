// serve.js — zero-dep HTTP server for OMNI web UI + SSE push.
import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join, dirname } from 'node:path';
import { Store } from './store.js';
import * as Q from './query.js';

// Module-level SSE client set so watcher can call broadcast() directly.
export const clients = new Set();

// Ring buffer of recent live events (projections w/ $) so a new client gets an
// immediate `snapshot` instead of a blank feed until the next event fires.
export const RING = [];
const RING_CAP = 300;

// Emit an SSE event whose name = obj.type ('event' for live deltas, else 'update').
// Live events are also retained in the ring for snapshot replay.
export function broadcast(obj) {
  if (obj && obj.type === 'event' && obj.ev) {
    RING.push(obj.ev);
    if (RING.length > RING_CAP) RING.shift();
  }
  const name = (obj && obj.type) || 'update';
  const data = `event: ${name}\ndata: ${JSON.stringify(obj)}\n\n`;
  for (const res of clients) {
    try { res.write(data); } catch (_) { clients.delete(res); }
  }
}

const __dir = dirname(fileURLToPath(import.meta.url));
const WEB_DIR = join(__dir, '..', 'web');
const INDEX_HTML = join(WEB_DIR, 'index.html');
const MIME = { '.js': 'text/javascript', '.css': 'text/css' };

function jsonReply(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) });
  res.end(payload);
}

export async function main({ DB, ROOT, argv = [] } = {}) {
  const port = Number(argv[0] || process.env.OMNI_PORT || 7777);
  const s = new Store(DB);

  const server = createServer((req, res) => {
    let url;
    try { url = new URL(req.url, 'http://x'); } catch (_) {
      jsonReply(res, 400, { error: 'bad url' });
      return;
    }
    const path = url.pathname;

    // SSE endpoint
    if (path === '/api/stream') {
      res.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      });
      res.write(':ok\n\n');
      res.write('event: snapshot\ndata: ' + JSON.stringify({ events: RING }) + '\n\n');
      clients.add(res);
      const keepalive = setInterval(() => {
        try { res.write(':keepalive\n\n'); } catch (_) { clearInterval(keepalive); clients.delete(res); }
      }, 25000);
      req.on('close', () => { clearInterval(keepalive); clients.delete(res); });
      return;
    }

    // Vendored static assets (uPlot etc.) — /vendor/<file>, no path traversal
    if (path.startsWith('/vendor/')) {
      const name = path.slice('/vendor/'.length);
      if (name.includes('/') || name.includes('..')) { jsonReply(res, 404, { error: 'not found' }); return; }
      const ext = name.slice(name.lastIndexOf('.'));
      try {
        const buf = readFileSync(join(WEB_DIR, 'vendor', name));
        res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream', 'Content-Length': buf.length, 'Cache-Control': 'max-age=86400' });
        res.end(buf);
      } catch (_) { jsonReply(res, 404, { error: 'not found', path }); }
      return;
    }

    // Static HTML
    if (path === '/') {
      let html;
      try { html = readFileSync(INDEX_HTML); } catch (e) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('index.html missing: ' + e.message);
        return;
      }
      res.writeHead(200, { 'Content-Type': 'text/html', 'Content-Length': html.length });
      res.end(html);
      return;
    }

    // JSON API routes
    try {
      if (path === '/api/status') {
        return jsonReply(res, 200, Q.status(s));
      }
      if (path === '/api/graph') {
        const project = url.searchParams.get('project') || null;
        return jsonReply(res, 200, Q.graph(s, { project }));
      }
      if (path === '/api/search') {
        const q = url.searchParams.get('q') || '';
        const project = url.searchParams.get('project') || null;
        return jsonReply(res, 200, Q.search(s, q, { project, limit: 30 }));
      }
      if (path === '/api/project') {
        const name = url.searchParams.get('name') || null;
        return jsonReply(res, 200, Q.projectSummary(s, name));
      }
      if (path === '/api/sessions') {
        const project = url.searchParams.get('project') || null;
        return jsonReply(res, 200, Q.sessions(s, { project, limit: 30 }));
      }
      if (path === '/api/dispatches') {
        const project = url.searchParams.get('project') || null;
        return jsonReply(res, 200, Q.dispatches(s, { project, limit: 40 }));
      }
      if (path === '/api/models') {
        return jsonReply(res, 200, Q.modelBurn(s));
      }
      if (path === '/api/health') {
        return jsonReply(res, 200, Q.health(s));
      }
      if (path === '/api/acronyms') {
        return jsonReply(res, 200, Q.acronyms(s, { project: url.searchParams.get('project') || null }));
      }
      if (path === '/api/remaining') {
        return jsonReply(res, 200, Q.remaining(s, url.searchParams.get('project')));
      }
      if (path === '/api/files') {
        const project = url.searchParams.get('project') || null;
        return jsonReply(res, 200, Q.fileHotspots(s, { project, limit: 80 }));
      }
      if (path === '/api/words') {
        const project = url.searchParams.get('project') || null;
        return jsonReply(res, 200, Q.words(s, { project, limit: 80 }));
      }
      if (path === '/api/burn') {
        const project = url.searchParams.get('project') || null;
        const model = url.searchParams.get('model') || null;
        const window = url.searchParams.get('window');
        if (window) {
          const bucket = url.searchParams.get('bucket') || null;
          return jsonReply(res, 200, Q.burnWindow(s, { window, bucket, project, model }));
        }
        return jsonReply(res, 200, Q.burnSeries(s, { project }));
      }
      if (path === '/api/rate') {
        const project = url.searchParams.get('project') || null;
        const model = url.searchParams.get('model') || null;
        const spanMin = +(url.searchParams.get('spanMin') || 60) || 60;
        const binSec = +(url.searchParams.get('binSec') || 60) || 60;
        return jsonReply(res, 200, Q.rollingRate(s, { spanMin, binSec, project, model }));
      }
      if (path === '/api/plan') {
        const project = url.searchParams.get('project') || null;
        const cap5h = url.searchParams.get('cap5h');
        const capWeek = url.searchParams.get('capWeek');
        return jsonReply(res, 200, Q.planUtilization(s, {
          project,
          ...(cap5h ? { cap5h: +cap5h } : {}),
          ...(capWeek ? { capWeek: +capWeek } : {}),
        }));
      }
      if (path === '/api/kpi') {
        const project = url.searchParams.get('project') || null;
        const model = url.searchParams.get('model') || null;
        return jsonReply(res, 200, Q.kpis(s, { project, model }));
      }
      if (path === '/api/waste') {
        return jsonReply(res, 200, Q.waste(s, {
          project: url.searchParams.get('project') || null,
          model: url.searchParams.get('model') || null,
        }));
      }
      if (path === '/api/punchcard') {
        return jsonReply(res, 200, Q.burnPunchcard(s, {
          project: url.searchParams.get('project') || null,
          model: url.searchParams.get('model') || null,
        }));
      }
      if (path === '/api/routing') {
        return jsonReply(res, 200, Q.routingFlows(s, {
          project: url.searchParams.get('project') || null,
          model: url.searchParams.get('model') || null,
        }));
      }
      if (path === '/api/timeline') {
        const project = url.searchParams.get('project') || null;
        const model = url.searchParams.get('model') || null;
        const spanMs = +(url.searchParams.get('spanMs') || 0) || undefined;
        return jsonReply(res, 200, Q.timeline(s, { project, model, ...(spanMs ? { spanMs } : {}) }));
      }
      // Unknown route
      return jsonReply(res, 404, { error: 'not found', path });
    } catch (err) {
      return jsonReply(res, 500, { error: String(err.message || err) });
    }
  });

  await new Promise((resolve, reject) => {
    server.listen(port, '127.0.0.1', () => resolve());
    server.once('error', reject);
  });

  console.log(`omni serve http://localhost:${port}`);
  return { server, broadcast };
}
