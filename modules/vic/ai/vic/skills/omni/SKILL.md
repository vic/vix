---
name: omni
description: Cross-project knowledge graph (ALL vic projects). Query the omni MCP BEFORE re-deriving anything that might already exist in another session/project — "what is X / what does ACRONYM mean", "where did we build/discuss Y", "what's the state of project Z", "what remains in W", "who touched file F", "which model/skill/tool was used", token-routing/burn audits, finding prior art across projects. Use at session start for cross-project orientation, before re-reading another project's code, and whenever an acronym/concept is unfamiliar. Prevents forgetting + saves tokens (recall beats re-derive).
---

# OMNI — cross-project knowledge graph + live web UI

omni indexes EVERY Claude Code session transcript (main + subagents) across ALL
vic projects into a queryable graph: projects · sessions · dispatched-agents ·
models · skills · tools · files · token burn · full-text of every prompt/title.
Source = `~/.claude/projects/*/**.jsonl` → `~/.claude/omni.db`. Live-updated.

## RULE: recall before re-derive
TOKENS = scarce. Re-reading another project or re-deriving a past decision is
WASTE when omni already has it. Query omni FIRST when the question is
cross-session or cross-project. Trust it like codegraph (it is a full parse,
not a guess) but VERIFY specifics against source before acting on them.

## MCP tools (mcp__omni__*)
- `omni_status` — global overview: counts, total token burn, top projects. Orient here first.
- `omni_search {q, project?}` — full-text over EVERY prompt/title/file. "where did we discuss X".
- `omni_project {name}` — one project: what was built (titles), burn, top tools/skills/files, per-model dispatch burn. Onboard here.
- `omni_sessions {project?, limit?}` — recent sessions: title, model, burn.
- `omni_dispatches {project?, limit?}` — per-agent telemetry (model, tokens, tools) ranked by burn. AUDIT token routing — find opus runs that should've been sonnet/haiku, and runaway (huge) dispatches.
- `omni_models` — token burn by model (routing-policy ground truth).
- `omni_concept {term}` — where a concept/acronym appears across projects (+ snippets). Resolve "what is X".
- `omni_files {project?}` — most-touched files (hotspots).
- `omni_acronyms {project?}` — glossary (TERM = def) from vic/ docs. Resolve an acronym BEFORE asking vic.
- `omni_remaining {project}` — OPEN items (LAW/OPEN/DEAD) — "what is left / current state of X".
- `omni_health` — token-routing audit (model %burn, runaway dispatches, cache, Read:codegraph) + recommendations.

## CLI / web (when vic asks to SEE it)
- `node ~/.claude/omni/omni.js status|search <q>|project <n>|dispatches|models|concept <t>`
- `node ~/.claude/omni/omni.js serve` → http://localhost:7777 live web UI (force graph,
  project panel, search, live SSE). `omni ingest` refresh · `omni watch` daemon.
- Dev source: this repo checkout (edit there, `bash install.sh` to deploy).

## when NOT to use
- Single-file / in-this-project structural questions → codegraph.
- Library/framework docs → deepwiki. omni is about VIC'S OWN session history.

## Learning reflex (recall-beats-re-derive — the $$ saver)

omni mines + stores LESSONS from past sessions and lets agents capture new ones. Recall is cheaper (fewer tokens) than re-deriving — that's the point.

### Tools
- **omni_recall {scope?, type?, query?}** — READ lessons: recurring error->resolution, dead-ends, and skill x model $$ efficacy (which skill+model solved a task-class cheapest). Call at task start / on first error.
- **omni_learn {type, signature, trigger?, resolution, scope, confidence?, related?, write?}** — WRITE one lesson. Dry-run by default (returns diff); write:'live' to persist. Promotes db -> memory -> skill by evidence. Never touches frontmatter.

### Reflex
1. RECALL-BEFORE-DERIVE — omni_recall before reasoning from scratch.
2. CAPTURE-AFTER-SOLVE — omni_learn after a verified non-trivial solve.
3. SAFE-CAPTURE — only non-obvious, verified, durable, terse, non-duplicate insights.

### Good vs bad lesson
GOOD: "uPlot in headless Electron -> black canvas on captureScreenshot; use canvas.toDataURL()." (specific, verified, non-obvious)
BAD: "always check docs" (obvious) / "maybe SSE times out" (unverified) / "ran npm install" (ephemeral).

Do NOT update/overwrite existing lessons — append-only; flag conflicts to vic.
