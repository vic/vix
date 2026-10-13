// watch.js — live graph maintenance. Event-driven fs.watch (recursive) ingests
// ONLY the changed .jsonl file, debounces multi-line bursts, throttles the FTS
// rebuild, and broadcasts each new event tagged with $ cost. A periodic safety
// reconcile (ingestAll) catches anything the OS watcher dropped.
import { watch } from 'node:fs';
import { Store } from './store.js';
import { ingestAll, ingestFile, fileMeta } from './ingest.js';
import { buildSearchIndex, eventCost, materializeLessons } from './query.js';

export function ingestOnce(store, root) {
  const out = ingestAll(store, root);
  let processed = 0, touched = 0;
  for (const k of Object.keys(out)) { processed += out[k].processed; touched += out[k].touched; }
  if (processed > 0) { buildSearchIndex(store); try { materializeLessons(store); } catch (_) {} }
  return { processed, touched };
}

export function startWatcher({ DB, ROOT, store = null, broadcast = null, reconcileMs = 30000, debounceMs = 150, log = () => {} }) {
  const s = store || new Store(DB);
  const own = !store;
  const timers = new Map();  // abs path -> debounce timer
  let idxAt = 0;
  const maybeIndex = () => { const now = Date.now(); if (now - idxAt > 2000) { idxAt = now; try { buildSearchIndex(s); } catch (_) {} try { materializeLessons(s); } catch (_) {} } };
  const flush = (abs) => {
    timers.delete(abs);
    try {
      const m = fileMeta(ROOT, abs);
      const r = ingestFile(s, abs, m.slug, m);
      if (r.processed > 0) {
        maybeIndex();
        if (broadcast) for (const ev of r.events) broadcast({ type: 'event', ev: { ...ev, usd: eventCost(ev) } });
        log(`+${r.processed} ${abs}`);
      }
    } catch (e) { log('flush error ' + e.message); }
  };
  const w = watch(ROOT, { recursive: true }, (_evt, fname) => {
    if (!fname || !String(fname).endsWith('.jsonl')) return;
    const abs = ROOT + '/' + String(fname).replace(/\\/g, '/');
    clearTimeout(timers.get(abs));
    timers.set(abs, setTimeout(() => flush(abs), debounceMs));
  });
  const recon = setInterval(() => {
    try { const { processed } = ingestOnce(s, ROOT); if (processed) log(`reconcile +${processed}`); } catch (_) {}
  }, reconcileMs);
  if (recon.unref) recon.unref();
  return {
    stop: () => {
      w.close(); clearInterval(recon);
      for (const t of timers.values()) clearTimeout(t);
      if (own) s.close();
    },
  };
}

export async function main({ DB, ROOT }) {
  console.log('omni watch: fs.watch live', ROOT, '(Ctrl-C to stop)');
  startWatcher({ DB, ROOT, log: (m) => console.log('[watch]', m) });
  await new Promise(() => {}); // run forever
}
