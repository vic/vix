// extract.js — enrich graph from <project>/vic/*.md docs: acronyms (TERM = def)
// + decisions under LAW/OPEN/DEAD headers. Rule-based (no LLM); nav-aid grade.
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { createHash } from 'node:crypto';

export const DECISION_STATUSES = new Set(['LAW', 'OPEN', 'DEAD']);
const h12 = (s) => createHash('sha1').update(s).digest('hex').slice(0, 12);

// acronym/glossary line: `TERM = definition` (TERM starts uppercase, 2-16 chars).
const ACR = /(?:^|[\s*-])([A-Z][A-Za-z0-9_]{1,15})\s*=\s*(\S.{2,90}?)\s*$/;
// status header line e.g. `## OPEN`, `### LAW (delivered)`, `## DEAD — ...`
const HDR = /^#{1,6}\s+.*?\b(LAW|OPEN|DEAD)\b/i;
const ANYHDR = /^#{1,6}\s+/;
const BULLET = /^\s*[-*]\s+(.+\S)\s*$/;

export function extractFromText(project, file, text) {
  const acronyms = [], decisions = [];
  let status = null;
  for (const raw of text.split('\n')) {
    const line = raw.replace(/\r$/, '');
    const hdr = line.match(HDR);
    if (hdr) { status = hdr[1].toUpperCase(); continue; }
    if (ANYHDR.test(line)) { status = null; continue; } // non-status header resets
    const a = line.match(ACR);
    if (a && a[1] !== a[1].toLowerCase()) acronyms.push({ term: a[1], def: a[2].slice(0, 120) });
    if (status) { const b = line.match(BULLET); if (b) decisions.push({ status, text: b[1].slice(0, 200) }); }
  }
  return { acronyms, decisions };
}

function vicDocs(projPath) {
  const dir = projPath + '/vic';
  if (!existsSync(dir)) return [];
  let rels;
  try { rels = readdirSync(dir, { recursive: true }); } catch { return []; }
  return rels.filter((r) => typeof r === 'string' && r.endsWith('.md'))
    .map((r) => dir + '/' + r).filter((f) => { try { return statSync(f).isFile(); } catch { return false; } });
}

// Walk every known project's vic/ docs, upsert acronym + decision nodes. Idempotent.
export function ingestDocs(store) {
  const projects = store.all("SELECT project FROM node WHERE kind='project'").map((r) => r.project);
  let nAcr = 0, nDec = 0, nFiles = 0;
  store.tx(() => {
    for (const p of projects) {
      for (const file of vicDocs(p)) {
        let text; try { text = readFileSync(file, 'utf8'); } catch { continue; }
        nFiles++;
        const { acronyms, decisions } = extractFromText(p, file, text);
        for (const a of acronyms) {
          const id = store.node('acronym', p + '::' + a.term, a.term, p, null, { def: a.def, file });
          store.edge('project:' + p, id, 'defines_acronym');
          nAcr++;
        }
        for (const d of decisions) {
          if (!DECISION_STATUSES.has(d.status)) continue;
          const id = store.node('decision', h12(p + d.status + d.text), d.status + ': ' + d.text, p, null, { status: d.status, file, text: d.text });
          store.edge('project:' + p, id, 'has_decision');
          nDec++;
        }
      }
    }
  });
  return { files: nFiles, acronyms: nAcr, decisions: nDec };
}
