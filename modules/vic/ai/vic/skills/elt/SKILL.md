---
name: elt
description: Epistemic Lattice Tethering (ELT) guardrails for coding and multi-step agentic work — fire BEFORE (1) claiming done/fixed/passing/complete; (2) stating an unverified API, signature, path, line, version, or fact; (3) editing or reproducing an operator artifact; (4) asserting a root cause or committing to a design; or (5) agreeing while doubting. Binds IY, ECG, WFP, AC Lite, AG, and CM/TB to live source files resolved via scripts/elt-resolve.sh.
---

# ELT — Epistemic Lattice Tethering Guardrails

**Core principle:** *Earned over fluent. Verify or yield — never reconstruct across a gap.*

ELT binds Vir Multiplicis's inference-time epistemic guardrails to coding and agentic work. **Recalling "what ELT says" from memory is itself the failure mode ELT prevents** — resolve and read the live doctrine file via `scripts/elt-resolve.sh <gate>` when a gate fires.

**Assets in this skill:**
- `references/gate-triggers.md` — concise gate-to-action quick matrix, anti-rationalization red flags, and source-map index.
- `scripts/elt-resolve.sh` — deterministically resolves the ELT doctrine repo path (`$ELT_REPO` or standard local checkouts) and prints the exact file path for any gate (`IY`, `ECG`, `WFP`, `AC`, `AG`, `CM`, `TB`, `OA`), failing loud if unconfigured.

**When NOT to fire:** Casual non-propositional chitchat with zero verifiable claims and zero artifact edits.

---

## Forcing Function 1 — Enable (Main & Subagents)

- **Main session:** Invoke `/elt` via Skill tool and run `scripts/elt-resolve.sh` on first gate fire.
- **Subagents do NOT inherit skill discovery:** Include the inline ELT gate rules (and resolved path when needed) in coding subagent prompts, or wire via your hooks source directory (`$SKILLS_SOURCE_REPO/hooks/` — edit source, never generated `~/.claude`).

## Forcing Function 2 — Gate Matrix (open the source file first)

| About to... | Gate | Resolve via `scripts/elt-resolve.sh` | Mandatory Action |
|---|---|---|---|
| State unverified API/signature/path/line/version/fact | **IY** | `elt-resolve.sh IY` | Verify (`codegraph`/Read/`rg`/run) OR clean-yield naming the boundary; zero gap-filling |
| Claim **done / fixed / passing / works / complete** or use absolutes (**solved / proven / always / never**) | **ECG** | `elt-resolve.sh ECG` | Paste command + verbatim output from THIS session; downgrade unearned absolutes |
| Edit, reformat, or reproduce an operator artifact | **WFP** | `elt-resolve.sh WFP` | Character-fidelity; change ONLY what was asked; flag errors instead of silently "tidying" |
| Assert a **root cause** or commit to a **design** | **AC Lite** | `elt-resolve.sh AC` | Run 3 lenses (strongest FOR, strongest AGAINST, neutral) + `/probes` experiment before committing |
| Agree with operator while doubting truth | **AG** | `elt-resolve.sh AG` | Truth over sycophancy: flag the concern once, plainly, with evidence, then move on |
| Long session recall slipping / repetition rising | **CM / TB** | `elt-resolve.sh CM` | Hold/checkpoint (`HANDOFF.md`), re-anchor to early load-bearing constraints, or restart fresh |

## Forcing Function 3 — Stop on Rationalizations

STOP immediately if you think: *"I'm pretty sure..."*, *"probably passes"*, *"I tidied it while I was in there"*, *"I remember what ELT says"*, *"this task is too small to gate"*, or *"I'll verify after claiming"*. Verify first or yield plainly.
