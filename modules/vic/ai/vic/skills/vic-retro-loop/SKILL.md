---
name: vic-retro-loop
description: Wave-end retrospective & continuous workflow optimization loop (ALL projects). Use at the end of every PM wave, at session end, after an agent fails/is killed twice, or when optimizing workflow/tiers/prompts. Gathers empirical metrics (gebed + outcome-based fail% + ccusage), diagnoses via vic-retro, applies owner-approved changes in jj workspaces, proves next wave or reverts, and persists verified lessons to source.
---

# VIC RETRO LOOP — Measure, Diagnose, Prove-or-Revert (vic, global)

**Stack:** `/vic-stack` (read telemetry and past mistakes from `quipu`; hand verified learnings to `#vic-shadow` or `vic-pm learn`) · `/jj` · `/br` (`gebed-pm`).

**Supreme rule:** A workflow/prompt/tier change ships ONLY if quality holds (oracles + reviews stay green) **AND** time or token burn drops. Faster-but-worse = REJECTED. Policy changes require `n >= 3` runs.

**Assets in this skill:**
- `references/retro-proposal-template.md` — structured hypothesis/metric/baseline/rollback proposal format so every `class:retro` experiment is provable and revertible.
- `scripts/retro-gather.sh` — gathers open `vic-pm br` `class:retro` experiments, recent `ccusage` breakdowns (if available), and prints the exact outcome-based Quipu SPARQL query (fixing the `vic-telemetry` `failed=1` hook bug).

---

## 1. The 7-Step Retro Loop

1. **Gather (read-only snapshot):** Run `scripts/retro-gather.sh` + `gebed_metrics` (velocity, rework rate, estimate error, stuck work) + `gebed_comments` on wave beads + Quipu `a:outcome` `fail%` query (do NOT trust `vic-telemetry classes` `failed` count for hook rows!). Also check open `class:retro` beads from the prior wave to prove-or-revert them.
2. **Diagnose (`vic-retro`, `opus/high`, read-only):** Give `vic-retro` the gathered metrics + failed prompts; it returns `<= 5` concrete proposals (each using `references/retro-proposal-template.md`) and creates `class:retro` beads via `vic-pm br`.
3. **Judge (owner gate):** Lead reviews proposals; **owner rules on every skill/agent/tier policy change** (zero silent policy edits).
4. **Apply:** Accepted proposals are edited in your skills/workflow source repo (`$SKILLS_SOURCE_REPO`) inside a clean `jj` workspace (`vic-rung`/`vic-scribe`); the `class:retro` bead stays **OPEN** with its named metric + rollback trigger.
5. **Prove (next wave):** Compare the named metric before vs. after on the next wave -> close bead with numbers if improved, OR **revert** cleanly if flat/worse.
6. **Learn:** Append verified traps/lessons via `vic-pm learn <file> "<lesson>"` (deduped). If a lesson ALREADY existed before the failure, it is a **reading/enforcement failure** — upgrade it from prose to a deterministic hook or verifier script!
7. **Record:** `vic-scribe` writes `pm/notes/retro-<YYYY-MM-DD>.md` + `quipu_episode` (`ledger:<proj>/retro/<date>`, verified via `quipu_ask references_to` after `quipu_validate`) and exports to `pm/quipu/`.

---

## 2. Temporal Learning & Proven Levers

- **As-of diagnosis:** Compare `quipu_query` at `tx: <wave-start>` vs. now; use `quipu_impact` (`remove: true`) before superseding an existing rule.
- **Tighten spec FIRST, bump tier SECOND:** Prompt clarity + armed oracle beat upgrading models.
- **Recurrence ratchet:** 2nd/3rd occurrence of a slip class -> move it from a prose rule into a mechanical hook/verifier (`brief-gate.sh`, `land-gate.sh`, `hook-agent-guard.sh`, `evidence-gate.sh`).
- **Fresh-context reviewer & 2-fail restart:** Writer != grader; after 2 failed corrections in one context, restart fresh with a sharper spec.
