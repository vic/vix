---
name: robin
description: Launch a persistent opus/high research sidekick ("robin") that the owner talks to directly; returns a cited DECISION artifact when the owner says done. Use on /robin <topic>.
---

# ROBIN — Persistent Research Sidekick (vic, global)

**Stack:** `/vic-stack` — `robin` recalls `quipu` and asks owning peer sessions via `ircc` before researching, and saves verified findings to `quipu`.

**Assets in this skill:**
- `references/robin-brief.md` — exact `agent-tier-gate.sh`-compliant spawn brief enforcing read-only research, verified `file:line`/URL citations, zero speculation, structured `DECISION` output, and context-refresh handover.

---

## Spawn & Lifecycle Rules

1. Spawn ONE `vic-robin` teammate compliant with `agent-tier-gate.sh`:
   - `subagent_type: "vic-robin"`
   - `model: "opus"`, `effort: "high"`
   - `name: "robin"`
   - `description: "opus/high: research <3-4 word topic>"`
2. Pass the topic from args (or `"stand by for owner's question"`) using `references/robin-brief.md`.
3. **Do NOT do the research yourself and relay nothing** — the owner communicates with `robin` directly.
4. **Never kill `robin`:** only the owner decides when `robin` ends. If `robin` approaches 75–80% context, ask `robin` to write a concise handover note to `<proj>/vic/notes/robin-handoff.md` before replacing it on the owner's call.
5. When the owner says `done`, ask `robin` for its final structured `DECISION` artifact and act strictly on that verified decision.
