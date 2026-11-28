---
name: escalate
description: Escalation & anti-thrash protocol (ALL projects) — 2-try-per-approach cap, 3-total-fails hard stop, law-underspec gate, owner-only decisions, and architecture-questioning boundary. Use immediately after 2 failed attempts on the same approach, any 3rd consecutive failure, spec underspecification, or scope/contract change. A crisp, cold-resumable escalation note is a deliverable; thrashing for hours is not.
---

# ESCALATION & ANTI-THRASH LAW (vic, global)

**Stack:** `/vic-stack` — save the escalation note as `ledger:<proj>/mistake/<slug>` or `evidence` in `quipu`, and notify the owning session via `ircc` (peers advise; only owner lines decide authority gates).

**Assets in this skill:**
- `references/escalation-template.md` — full cold-resumable `# ESCALATE` artifact template + 1-page owner decision memo format.
- `scripts/escalate-init.sh` — scaffolds a pre-populated `# ESCALATE` note with VCS commit, repo state, and required sections so zero dead paths are ever forgotten.

---

## 1. Hard Triggers (ANY ONE -> STOP THE LINE NOW)

1. **2-Try Approach Cap -> Mandatory Change on Try 3:**
   - The SAME approach (fix, probe, perf tweak, mutant, test) may fail at most **TWICE**.
   - Before try 3, you MUST change something real: escalate to a stronger coder tier with the exact brief, OR redesign from fresh measurements/probes at the highest designer tier. NEVER a 3rd try with the same tier and same design.
2. **3 Total Fails on Same Target -> HARD STOP + Question Architecture:**
   - Stop coding immediately. Write an `# ESCALATE` artifact (`scripts/escalate-init.sh`) and question the underlying architecture or invariant. *"One more try"* is a banned rationalization.
3. **Spec Underspecification (`UNDERSPEC`):**
   - Search ALL spec documents (grammar, rules, AND examples) first. If no spec anchor licenses the behavior either way (`vic-lawyer` `UNDERSPEC`), NEVER guess semantics — route `vic-lawyer` -> `vic-derive` / owner ruling.
4. **Owner-Only Authority Gates (no agent decides):**
   - New dependency (including dev-deps) · encoding/wire representation change · spec/law departure · consumer contract (`I`) break · scope swap/redesign · autonomous push · deleting corpus/docs.
5. **Invalid-Data Smell:**
   - If fixing a bug requires more `if` checks at read sites instead of making invalid data unrepresentable at the write site -> stop and route to type-enforcement redesign (`vic-typesmith`).
6. **Tier or Overload Breach:**
   - Worker hitting design freedom or context overload -> apply the PIE Restructure Move (`/pie`: split element, keep `I` stable), not blind retries.

---

## 2. Routing Table

| Failure Class | Mandatory Route |
|---|---|
| Mechanical / brief flaw | Fix brief as `<ID>-v2` + new SHA, retry same tier |
| Missing isolation / large repro | `vic-isolate` (shrink to `< 1 s` `MINREPRO` + flip table) |
| Root cause unclear | `vic-hunter` (instrument/trace/counters — no blind theories) |
| Perf gate miss | `/probes` (`callgrind` / `perf record` / ablation stub — zero blind tweaks) |
| Law/spec ambiguous | `vic-lawyer` (cite court across all docs) |
| Law genuinely absent | `vic-derive` -> 1-page owner ruling memo |
| Owner decision needed | 1-page memo: concrete options A/B/C + measured receipts + marked recommendation (NEVER open-ended *"what should we do?"*) |

---

## 3. Anti-Patterns (banned — burned hours historically)

- Silent retry past 2 on the same approach, or past 3 total.
- Workaround instead of escalation (`skip`/`#[ignore]`/`sleep`/band-aid `if`/weakened test).
- Escalating verbally without writing the `# ESCALATE` file to disk (context dies; disk survives).
- Escalating without the **RULED OUT** dead-paths list (next session re-walks the same dead ends).
- Asking the owner a question that a spec document already decides.
