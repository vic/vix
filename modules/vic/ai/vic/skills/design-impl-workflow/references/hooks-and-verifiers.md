# Hooks, verifiers, oracle archetypes, and report formats (generic)

System prompts yield ~70–90% compliance under long chains and context fatigue. Reliable multi-agent engineering shifts critical laws out of prose into **deterministic control surfaces**: automated hooks, static/runtime verifiers, and machine-checkable receipts that run outside the LLM's reasoning loop.

Ready-to-run, zero-dependency POSIX `sh` tools ship in this skill's `scripts/` directory.

---

## 1. Deterministic control stack

```text
  [ Brief Authoring / Hardening ]
        │
        ▼
  1. Pre-Dispatch Verifier (`scripts/brief-gate.sh`)
     Blocks placeholders, missing sections, pipe-masked exits, sentinels, unverified mutant anchors
        │
        ▼
  2. Live Agent Guardrail Hook (`scripts/hook-agent-guard.sh`)
     PreToolUse / shell wrapper blocking pkill -f, sleep-poll, VCS writes in worker lanes,
     pipe-masked exits, chained `st && new`, unguarded log overwrites
        │
        ▼
  3. Build + Multi-Oracle + Mutant + Perf Execution
     GCC + Clang (-Wall -Wextra -Werror -pedantic) + ASan/UBSan + Goldens + Mutants + Perf Agent
        │
        ▼
  4. Pre-Land Verifier (`scripts/land-gate.sh`) & Perf Gate (`scripts/perf-gate.sh`)
     Clean-restore SHA-256 proof, 0 mutant residue, exact FILES diff-stat, static hygiene,
     deterministic instruction/RSS gate, atomic perf-log append
        │
        ▼
  5. Durable Verification Receipt + Post-Land Audit (`[verify-commit]` -> `[verify-result]`)
```

---

## 2. Included POSIX `sh` verifier scripts (`scripts/`)

All scripts are strictly POSIX `sh` (zero Python dependency, portable across Linux/macOS/CI).

| Script | When to run | What it enforces |
|---|---|---|
| `scripts/brief-gate.sh <brief> [--repo <dir>]` | Before staging and before dispatching every brief | Rejects `<PLACEHOLDER>` tokens, missing required sections (`TASK`, `TICKET`/`BEAD`, `GOAL LINE`, `AGENTS`, `FILES`, `CONTRACT`, `COMMANDS`, `STEPS`, `MUTANTS`, `EXPECT`, `PERF`, `FAILURE-PATTERN`, `REPORT`), missing 10-minute cap, tracker CLI hints on ticket line, mentions of owner/user to implementer, line-number edit instructions, pipe-masked `EXIT=$?`, sentinel specs, multi-line `sed -i`/`perl -i` instructions; optionally verifies mutant anchors have `rg -Fc == 1` in `--repo`. |
| `scripts/hook-agent-guard.sh [--worker] [--cmd "..."]` | Wired into agent `PreToolUse` shell hooks (reads JSON stdin or `--cmd`) | Deterministically denies `pkill -f`, `killall`, `pgrep -f \| xargs kill`, `sleep`-polling loops, pipe-masked exit codes (`\| ...; echo EXIT=$?`), chained `jj st && jj new` / `git status && git ...`, unguarded log truncations (`> ...perf-log.tsv`), and (with `--worker`) any state-changing VCS command or multi-line `perl -i`/`sed -i`. Exits non-zero with exact denial reason. |
| `scripts/land-gate.sh --repo <dir> --files <allowed.txt> [--manifest <clean.sha256>] [--strict-switch]` | Before committing/landing every lane | Verifies: (1) clean-restore SHA-256 manifest matches every mutated file on disk; (2) changed files in VCS diff are a subset of `--files` (flags any drift); (3) zero VCS conflicts/divergence (`jj` or `git`); (4) zero banned production tokens (`TODO`, `FIXME`, `XXX`, `abort(`, `exit(`, `panic(`) or mutant residue markers in changed production files; (5) optional zero disallowed `default:` arms under `--strict-switch`. Emits a concise PASS/FAIL receipt. |
| `scripts/perf-gate.sh --label <L> --base-instr <N> --cand-instr <N> --base-rss <K> --cand-rss <K> [--max-instr-pct 1.0] [--max-rss-pct 2.0] [--wave-base-instr <N>] [--log <perf-log.tsv> --commit <H> --dep <H>]` | During perf agent evaluation and acceptance | Computes deterministic percentage deltas via `awk`, gates instructions (`+1.0%`) and peak RSS (`+2.0%`) plus optional cumulative wave drift, prints standardized `GATE PASS` / `GATE FAIL` line, and optionally appends to a TSV log via **atomic temp-file + row-count monotonicity check (`new > old`) + `mv`**. |

### Wiring `hook-agent-guard.sh` into harness hooks
- **Claude Code / compatible JSON PreToolUse hook:** Configure a `PreToolUse` matcher on shell/Bash tool calls pointing to `scripts/hook-agent-guard.sh --worker` (for coding/mutant/perf subagents) or `scripts/hook-agent-guard.sh` (for coordinators). The script inspects stdin JSON or `--cmd` and exits `2` with a clear stderr message on violation.
- **Git / JJ pre-commit or CI gate:** Call `scripts/land-gate.sh` in CI or local landing scripts before rebasing onto `main`.

---

## 3. Additional static & runtime verifier patterns to adopt per project

Adopt the subset that matches your language and architecture:

1. **Multi-compiler + sanitizer matrix (every task):**
   - Two distinct compilers (e.g., GCC + Clang) with strict warnings-as-errors (`-Wall -Wextra -Werror -pedantic -Wswitch -O2`).
   - AddressSanitizer + UndefinedBehaviorSanitizer (`ASAN_OPTIONS=detect_leaks=1:allocator_may_return_null=1`) without virtual-address `prlimit` (ASan reserves ~15 TB virtual space).
2. **Explicit inline symbol gate (`nm`):**
   - For hot cross-TU helpers declared `static inline`, run `nm <binary> | grep -E ' T (<helper1>|<helper2>)$'` and fail if any out-of-line symbol appears.
3. **Static stack-frame budget gate (`-fstack-usage`):**
   - Compile with `-fstack-usage` and fail if any function exceeds the project's frame byte cap or reports `dynamic`/`unbounded` stack allocation (VLAs). Pair with a runtime stress test under `ulimit -s 1024`.
4. **Hardening / barrier disassembly oracle (`objdump`):**
   - On security-critical code (bounds masks, constant-time ops, speculation barriers), inspect `-O2` disassembly from BOTH compilers to assert the compiler did not optimize away the barrier.
5. **Compile-and-run emitted-code oracle:**
   - When the system generates target code (C, assembly, bytecode, SQL), compile/execute the emitted artifact with two independent toolchains at `-O2 -Werror` and assert exact exit codes and outputs.
6. **Architecture / dependency boundary tests:**
   - Enforce layering, forbidden imports, zero hardcoded local absolute paths, and single-producer ownership mechanically in CI (e.g., custom `rg`/AST linter, `ArchUnit`, `dependency-cruiser`, Clippy/ESLint rules).
7. **Deterministic instruction-count + RSS harness:**
   - Use hardware user retired instructions (`perf stat -x, --no-inherit -e instructions:u`) or deterministic software emulation (`callgrind`) + median peak RSS across `>= 2` runs on an idle host.
   - Two-stage confirmation: fast screen on perf agent -> interleaved same-input A/B confirmation on any gate miss before blocking.

---

## 4. Reusable probe & oracle archetypes

| Archetype | Implementation Pattern | What It Prevents |
|---|---|---|
| **Spec-to-Golden Extractor** | `sh` + `awk` script extracting normative rule blocks and test cases directly from fenced Markdown spec sections into a regenerated directory (never mixed with hand-written files). | Spec-to-test drift and stale orphaned tests. |
| **Whole-Program Golden Runner** | Runs every test family against the *complete* combined verifier under `timeout` + `prlimit --as=...`, sorting outputs and diffing missing relations + rows. | Cross-module regressions missed by isolated family tests; hanging/OOM tests. |
| **All-Output Diagnostic Probe** | Scratch wrapper exposing *all* internal intermediate relations/states as outputs and diffing against expected unnamed rows. | Hours guessing which internal rule dropped or failed to derive a row. |
| **Manifest-Verified Payload Courier** | Copies generated payloads between design and impl repos (when impl is idle) and checks `sha256sum -c`. | Partial/corrupted transfers or silent spec-vs-impl drift. |
| **Sharded Seed-Shuffle Runner** | Splits order-independence/fuzz tests into fixed-size slices under `timeout`, parameterized by shuffle seed and thread count, asserting byte-identical outputs via `cmp`. | Suite timeouts hiding non-determinism or ordering bugs. |
| **Bidirectional Mechanical Translator + Stats Audit** | Forward generator emitting `stats.txt` (`unmapped=0`, `unnamed=0`, `leftover=0`) + reverse exporter checked against canonical spec modulo clause order. | Silent loss/mistranslation in bulk generated code. |
| **Micro Standalone Stage Probes** | Tiny (15–40 LOC) executables linking internal pipeline stages (lex/parse/resolve/IR/extract) to print exact structures on small fixture trees. | Guessing test expectations in briefs; hidden unchecked preconditions. |
| **Multi-Transport Parity + Flat-RSS Leak Oracle** | Sends identical framed workloads over CLI, socket, and protocol transports; asserts byte-identical replies with real content checks + `0 KB` RSS growth across 1,000 requests. | Transport divergence, weak pass-through tests, slow memory leaks. |
| **Differential Oracle + `ddmin` Shrinker** | Runs reference vs. candidate (or stage-0 vs. stage-1) on identical inputs, compares verdict sets + normalized relation multisets in both directions (unsoundness AND incompleteness), and auto-runs `ddmin` delta minimization on divergence. | Subtle semantic divergence; huge unreadable counterexamples. |
| **Reference Inventory Snapshots** | Checked-in plain-text inventories (required mappings, unmodeled constructs, unreferenced defs) diffed whenever schemas grow. | Silent coverage regressions or uncounted new variants. |

---

## 5. Standardized report & ledger formats

### 5.1 Lane completion report (implementer -> design, <= 25 lines)
```text
LANE <lane> <ID>
AGENTS: code=<model>/<effort> <start>-<end>Z; mutant=<model>/<effort> <start>-<end>Z; perf=<model>/<effort> <start>-<end>Z
FILES: <diff --stat summary>
RESTORE-SHA: <file1>=<sha256> (MATCH); <file2>=<sha256> (MATCH); residue=0
RED: <exact failing test lines before code>
GREEN: build(gcc,clang,san)=0warn; gcc=<N>/<N>; clang=<N>/<N>; san=<N>/<N>; golden=<G>/<G>; check=<verbatim line>
MUTANTS: m1=FAIL(<checks>) restored; m2=FAIL(<checks>) restored
PERF: <label>: instr <cand> vs <base> (<delta>%) rss <cand> vs <base> (<delta>%) -> GATE PASS|FAIL
DRIFT: none | <verbatim list of every deviation>
```

### 5.2 Audit commit-verification protocol (board / peer messages)
- **Trigger (design -> audit, immediately upon landing):**
  `@audit [verify-commit] <commit-hash> <ID> (ticket <ticket-id>, brief <brief-path>)`
- **Verdict (audit -> design):**
  `@design [verify-result] <commit-hash> <ID>: CLEAN`
  OR structured findings with monotonic IDs (`C<n>`), severity (`P0` / `P1` / `P2`), `file:line`, spec/tenet/ruling bar violated, and minimal reproduction probe.
- **Triage reply (design -> audit):**
  `C<n>: verified (P0 -> brief <ID> dispatched | P1/P2 -> queued on <phase/file>) | refuted (<repro command + output>) | deferred (<reason + target phase>)`

### 5.3 Numbered ruling entry (newest first in rulings ledger)
```markdown
## R<nn> — <short title> (<YYYY-MM-DD>, task <ID>, ticket <ticket-id>)
- **Evidence:** `<spec-file:line>` "<exact quote>"; probe/audit `<id>`
- **Decision:**
  1. <concrete normative rule>
  2. <concrete scope / follow-up / conversion debt if interim>
- **Spec fix:** `<spec-file:line>` updated to "<exact new wording>" (or `none — spec already unambiguous`)
```

### 5.4 Per-stage effort & metrics report (for issue tracker at acceptance)
| Stage Agent Name | Minutes | Actual Weight | Capacity | Key Fields |
|---|---|---|---|---|
| `impl-agent <model>/<effort>` | code + mutant mins | diff-size Fibonacci (1..21) | `1` | attempts, testsPass, testsFail, complexity (1–5) |
| `perf-agent <model>/low` | perf mins | *(omit)* | *(omit)* | gate pass/fail, deltas |
| `design <model>` | cycle minus other stages | *(omit)* | `1` | commit hash, rulings, estimate vs actual, own slips |

*(Omit cycle minutes when the gap includes an outage or design pause; omit unknown fields rather than guessing zero; never submit two minute-bearing reports for the same stage.)*

### 5.5 Own-mistake ledger format (append immediately on every slip)
```text
- OWN MISTAKE <YYYY-MM-DD HH:MM> (<task/audit-id>, occurrence #<k> of class <class>):
  <exact what happened> -> <concrete rule or automated gate added>
```
*(Rule of recurrence: on occurrence #2 or #3 of any mistake class, upgrade from a prose rule to a mechanical check in `scripts/brief-gate.sh`, `scripts/land-gate.sh`, or `scripts/hook-agent-guard.sh`.)*
