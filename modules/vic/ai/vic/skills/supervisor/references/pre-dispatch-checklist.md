# Supervisor Binary Pre-Dispatch & Acceptance Checklist

## Before Every Spawn (ALL must be YES)
- [ ] **P -> I -> E:** 1–2 line consumer Purpose, typed Interaction contract/oracle, and Element tier chosen LAST.
- [ ] **Root / Lever Proven:** Dynamic root cause confirmed via probe, OR perf lever sized via release ablation (`evidence-gate.sh` `verdict: PASS`).
- [ ] **Contradictions Settled:** Every spec conflict/ruling cited was OPENED and resolved before dispatch.
- [ ] **Oracle + Mutant Armed:** Runnable RED check + compilable product-site mutant + clean-restore SHA step included.
- [ ] **No-Explore Leash:** Exact `FILES`, `NOT-SCOPE`, pre-debunked dead ends, inline coding laws, and `<= 5–10 min` cap stated.
- [ ] **Workspace & Disjointness:** Fresh isolated `jj` workspace created; `FILES` (src + tests + deps) disjoint from all active lanes; worker forbidden all `jj`/`git`.
- [ ] **Tier & Label:** `description: "<model>/<effort>: <3-5 words>"` + explicit `model` matching prefix.

## Before Accepting / Landing Any Return (ALL must be YES)
- [ ] **Disk Verified:** `jj -R <ws> st` + `diff --stat` strictly within `FILES`.
- [ ] **Clean Restore:** Pre-mutant SHA-256 manifest matches disk (`0` live mutants, `0` residue).
- [ ] **Independent Verification:** Multi-compiler + sanitizer + golden + integration counts verified on freshly built workspace binary.
- [ ] **Perf & Hygiene:** Deterministic instruction (`+1%`) & RSS (`+2%`) gate passed; `0` warnings; `0` disallowed `default:` / placeholders.
- [ ] **Tracked:** Linearly landed (`/jj`), auditor notified (`[verify-commit]`), `gebed_report` + `HANDOFF.md` + `state.md` updated.
