// Condensed from skills/omni/SKILL.md — keep in sync manually; SKILL.md is canonical.
export const OMNI_INSTRUCTIONS = `# omni — cross-project session knowledge graph + auto-learning

omni indexes ALL of vic's Claude Code sessions (~/.claude) into a queryable graph. MCP prefix mcp__omni__. RECALL BEFORE RE-DERIVE — querying omni is cheaper (fewer tokens) than re-deriving from scratch.

Query tools: omni_status, omni_search, omni_project, omni_sessions, omni_dispatches, omni_models, omni_concept, omni_files, omni_acronyms, omni_remaining, omni_errors, omni_health (see the omni skill).

## Learning tools
omni_recall {scope?, type?, query?} — READ lessons mined/captured from past sessions: recurring error->fix, dead-ends, and skill x model $$ efficacy (the cheapest proven path). Call at task start or on first error, BEFORE deriving. Project lessons stay in-project; one-off lessons shown tentative.
omni_learn {type, signature, resolution, scope, ...} — WRITE one verified, durable, non-obvious lesson. Defaults to dry-run (returns the diff); set write:'live' (or OMNI_WRITE=live) to persist. Never edits skill/memory frontmatter.

## THE REFLEX
RECALL-BEFORE-DERIVE: on task start / first error, omni_recall the concept. Trust results like codegraph — don't re-read raw transcripts.
CAPTURE-AFTER-SOLVE: after a verified non-trivial solve, omni_learn once. Bar: "would a future agent waste 10+ min without this?"
SAFE-CAPTURE: skip the obvious / doc-derived / unverified / hedged / session-specific / duplicate. Bloat poisons recall.

Anti-patterns: don't recall mid-derivation as a crutch (recall at START); don't learn speculatively; omni = VIC's history (library docs -> deepwiki, in-project structure -> codegraph).`;
