---
name: oracle
description: Oracle-first & mutation-testing law (ALL projects). Use BEFORE writing any spec, implementation, or fix, and whenever validating a "green"/"passing"/"it works" claim or distrusting a suite. Triggers — acceptance test, oracle, mutant, negative control, differential test, ddmin, "how will we know it's fixed", verify an agent's result, suspicious pass. A weak or cheatable oracle is worse than none.
---

# ORACLE & MUTATION-TESTING LAW (vic, global)

**Stack:** `/vic-stack` — recall `quipu` evidence for the same claim first; record oracle + negative-control + clean-restore proof as `ledger:<proj>/evidence/<slug>`.

**Assets in this skill:**
- `references/oracle-catalog.md` — all 7 oracle shapes, differential + `ddmin` shrinker pattern, adversarial mutant design rules, and multi-compiler/sanitizer/stack/disassembly hardening oracles.
- `scripts/mutant-runner.sh` — automated, clean-restore SHA-256 verified mutant executor (verifies unique 1-line anchor, applies mutant, runs check expecting FAIL, restores clean snapshot, proves byte-identical `sha256sum` + `cmp`).

---

## 1. Oracle Hierarchy (strongest first)

1. **Two independent paths agree (differential oracle):** Implementation vs. independent reference tool/language or stage-0 vs. stage-1 comparison on identical inputs — neither can cheat the other. Pair with `ddmin` delta-minimization on any divergence.
2. **Whole-program golden suite:** Evaluate against the *complete integrated* rule/verifier program, never only isolated per-family slices (catches cross-family obligations).
3. **Exact spec-derived values:** Independently derived hashes, canonical encodings, AST dumps, or exact rejection counts (ban weak `count > 0` or copied-from-code assertions).
4. **Property / invariance oracles:** Bijective round-trip (`decode(b) = Ok(o) ==> encode(o) == b`), order-independence shuffles (`cmp` across seeds/threads), multi-transport byte-identical parity, flat-RSS across 1,000 requests (`0 KB` growth).
5. **Counter signature:** Exact counts obeying a known law, asserting counter `>> 1` (counter `= 1` or `0` measures nothing).
6. **Hardening / compiler oracles:** Multi-compiler (`gcc` + `clang` `-Wall -Wextra -Werror -pedantic -O2`) + ASan/UBSan (`detect_leaks=1`), `-fstack-usage` + `ulimit -s 1024`, `nm` inline-symbol check, `-O2` `objdump` barrier check.
7. **Exit-code gate:** Weakest alone — always combine with shapes 1–6.

---

## 2. Mandatory Negative Controls & Mutants

- **Armed control law:** Every green check or zero-count scan ships with a negative control proving it **FAILS** on a broken input or mutant. An unarmed green check or zero-hit scan with no positive control is **zero evidence**.
- **Product-site compilable mutants:** Mutate a condition, constant, argument, or string at the **production site** (e.g., allocation site, not just a test helper) so it COMPILES with zero warnings under `-Werror` and has ONE exact predicted outcome naming every failing check (both paths for dispatch mutants; full cascade for early-step mutants). Never delete a call/loop (triggers `-Werror=unused-*`).
- **Compile-fail exhaustiveness mutants:** For closed-enum switches omitting `default:`, include a mutant deleting one `case` proving the build FAILS with `-Wswitch -Werror`.
- **Zero-waiver surviving mutants:** A surviving mutant either proves **dead/redundant code** (delete it!) or exposes a **weak fixture** (unsort inputs for sort mutants, keep pipe open past bound for length mutants, use non-zero offsets for arena-OOB mutants invisible to ASan). List intentionally unmutated paths (e.g., OOM without fault injection) explicitly.
- **Clean-restore SHA-256 gate:** Save a clean snapshot before mutating, run via `scripts/mutant-runner.sh`, and prove byte-identical restore (`sha256sum` + `cmp`) before landing.

---

## 3. Classic Oracle Traps

- **Tests asserting a bug:** A right fix breaks them. Independently derive truth from the spec, record a numbered ruling, THEN update the test. Never blindly edit expectations to match code.
- **Early-rejecting fixtures:** Verify fixtures pass through all intended pipeline stages (`rejects=0`, `steps=...`).
- **Sharing-blind tests:** Exercise internal sharing with compounding inputs; trivial inputs hide sharing bugs.
- **Hand-computed indices:** Derive index tables in comments and verify against a listing first.
- **Agents cheat tests:** "`N` tests pass" means nothing. Demand RED -> GREEN -> mutant-FAIL -> clean-restore SHA pastes, and inspect the diff to ensure no oracle was weakened.
- **Unguarded subprocesses & flaky floats:** Every spawned process gets a kill timer; wall-clock/float assertions are forbidden in correctness oracles.

## Law
No implementation dispatched without an oracle written and **RED confirmed**. No task accepted without oracle output + mutant kill + clean-restore SHA pasted verbatim.
