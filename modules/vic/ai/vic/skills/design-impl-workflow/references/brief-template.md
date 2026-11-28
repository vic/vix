# Brief templates (generic: TASK, PROBE, LAND-VERIFY)

A brief is the entire world of the implementer and its worker agents. They have no design docs and no memory of prior sessions. Fill every field; a field that does not apply says `none` and why.

**Pre-staging invariants (enforce with `scripts/brief-gate.sh`):**
- Zero unfilled placeholders (`rg '<[A-Z_]+>'` returns empty).
- Ticket/bead ID appears on the `BEAD` / `TICKET` line (plain ID only — zero tracker CLI flags or tool hints).
- Never mention or quote the human owner anywhere in a brief to the implementer.
- Inline the governing coding laws directly in `FIXED AGENT LINES` (worker subagents often lack harness skill loaders — never write "invoke Skill X").
- Never re-stage an already-dispatched brief in place: any revision after dispatch MUST be `<ID>-v2` with a new SHA-256 and an explicit dispatch notice.
- Large exact text (headers, fixtures, generated payloads): stage under the lane/build staging path with a `sha256sum` manifest; keep the canonical source in design notes.

---

## 1. Standard TASK BRIEF template

Message shape accepted by implementers (other shapes were refused): first line is `TASK BRIEF from @design, the lead of this project (self-contained).` Acceptance notes and drift rulings from the prior task go ONLY inside `STATE NOW`, never before the brief.

```text
TASK BRIEF from @design, the lead of this project (self-contained).

ROLES: @design decides design, names, files, tests and order, writes every brief, reviews, accepts, commits and
lands. You (@impl) verify staged hashes, dispatch one fresh subagent per step, rerun the checks, inspect diff-stat
and report. You never design, invent names, commit, or code in your own shell.
WHO YOU ARE: <role, repository path, allowed extra read-only paths, project law file path to re-read first>
FIRST: verify every staged file hash (sha256 below). Mismatch -> stop and tell @design. Re-read the law file.
STATE NOW: <main tip change/commit hash, test counts per compiler + sanitizer, golden + check line verbatim,
           last acceptance notes, drift rulings>
LANE: <lane name, isolated workspace path, base tip hash>   (agents run NO VCS commands)
STAGED FILES: <staged brief path> sha256=<64-hex>  [<extra payload/header paths + sha256>]

TASK <ID>: <one-line title>
TICKET: <ticket-or-bead-id>   (ID only; zero CLI hints)
GOAL LINE: moves critical path by <one line>; wired into production path by <this task | task ID>

AGENTS (one fresh subagent per step; model/effort named; 10-minute cap each;
        description "<model>/<effort>: <ID> <step>"):
  code agent: <model>/<effort>
  mutant agent: <model>/<effort>
  perf agent: <fast-model>/low (fresh context, zero implementation memory)

FIXED AGENT LINES (paste verbatim into every worker prompt):
  - Work ONLY inside the named lane workspace path and explicit read-only paths; never list parent directories.
  - Re-read <repo-law-file> first. Follow core laws: illegal states unrepresentable (closed enums, typed outcomes,
    no sentinels or overloaded bools, no default: on closed-enum switches); no abort/exit/panic/todo/skip/stub;
    zero warnings across all compilers + sanitizers; full-word names (no 1-2 letter names, no trailing digits);
    fix invariants at the producer; bounded stack and indexed lookups.
  - Run NO VCS commands (no commit, rebase, restore, status-mutation).
  - Run every build in the foreground, one at a time (never background builds).
  - Run every command under timeout (<= 120 s) and memory cap (except sanitizers); capture output to a file, then
    echo EXIT=$? immediately after the command (never after a pipe).
  - Multi-line edits via structured Edit/Write tools only (never multi-line sed/perl/awk or truncate).
  - Stop at 10 minutes or after 2 failed fix attempts. On any mismatch or gap: stop, change nothing, report verbatim.
    Never edit an expected value or pick a different command.

WHY:
  - Specs: <spec-file:line> "<exact quoted sentence>" (rules AND examples checked)
  - Rulings opened and verified against every step: <Rnn — exact decision relevant to each step>

FILES (EXACT list; disjoint from all active parallel lanes — source AND test/count files; anything else is drift):
  - <path/to/file1>
  - <path/to/file2>
  Expected diff-stat: <N files changed>

CONTRACT:
  - Headers/APIs (compile-checked on two compilers): exact types, closed enums, struct fields, signatures,
    static helper names (every name ruled; hot cross-TU helpers marked static inline + call frequency stated).
  - Behavior: one sentence per function; typed outcomes (kind + payload); validated entry wrappers;
    no fixed-size text caps; producer-derived buffer/arena capacities.
  - Complexity: O(...) of every new loop/lookup and the spec bar it meets; stack bound (iterative on deep chains).
  - Edits anchored by exact existing text (NEVER line numbers).

COMMANDS (copy exact invocations; every binary run is built by a step here; capture output -> echo EXIT=$?):
  - Build (clean old binaries first): <exact multi-compiler + sanitizer build command>
  - Unit tests (compiler 1, compiler 2, sanitizer with detect_leaks=1)
  - Integration / golden / static hygiene checks (e.g. zero disallowed default: arms, nm inline check)

STEPS:
  1. Write the new checks FIRST (names, inputs, exact expected values below). Run them: MUST BE RED.
     Paste the exact RED lines.
  2. Implement per CONTRACT. Build: 0 warnings on all compilers + sanitizers.
  3. Run all COMMANDS. Expected GREEN count: <exact count> (tag unmeasurable pre-build values INFERRED).
     STOP and report any mismatch verbatim.
  4. Save clean pre-mutant snapshots (`mutant-save-<file>`) and record their sha256sum.
  TEST LIST: <exact check names, parser-probed legal inputs, exact expected values, full sorted fixture index table,
              every existing test expectation affected (verified via rg)>

MUTANTS (exact before text READ on real lane file with rg -Fc == 1 [or marked predicted for new code];
         exact after text compiles with 0 warnings under -Werror [or explicit compile-fail -Wswitch mutant];
         hits the product path; ONE exact predicted outcome naming EVERY failing check; restore proved by sha256/cmp):
  - m1 (<file>, anchor rg -Fc = 1):
      before: `<exact single/multi-line text>`
      after:  `<exact mutated text>`
      predict: FAIL <exact check names (both paths if dispatch mutant; full cascade if early step)>
  - m2 (compile-fail exhaustiveness mutant, if closed-enum switch added):
      delete `case <Variant>:` -> predict: BUILD FAIL with -Wswitch
  Unmutated gaps (explicit): <e.g., OOM branches without fault injection>

EXPECT:
  - Unit tests: <N>/<N> pass (0 fail) on compiler 1, compiler 2, sanitizer
  - Golden / integration: <exact expected output line>
  - Mutants: <K>/<K> killed as predicted; clean-restore sha256 identical; 0 mutant residue
  - Diff-stat: strictly FILES list

PERF AGENT (separate fresh agent, quiet host, one benchmark at a time):
  - Commands: <measure commands with `<label>Candidate<ID>` labels>
  - Baselines (newest LAND-VERIFY'd main tip on SAME host, commit <hash>, dep <hash>):
      <label>: instr=<N>, rss=<K> KB
  - Bar stated BEFORE build: <= +1% instructions, <= +2% peak RSS (median of >=2 runs) per benchmark
    [or explicit per-output denominator if adding required output with non-zero baseline].
  - Print one gate line per bench: `<label>: instr <cand> vs <base> (<delta>%) rss <cand> vs <base> (<delta>%) -> GATE PASS|FAIL`.
  - Never edit code to chase a number; report verbatim.

FAILURE-PATTERN BOX (one concrete line per check; plus RULE-FAMILY BOX if touching declarative rules):
  - Unmodeled / fail-closed: <how unknown/unmodeled cases reject>
  - Reader / wiring: <production reader or next wiring task>
  - Rule vs host decision: <whether user errors stay in rules; interim fail-closed list>
  - Identity / IDs (no name lists): <verified>
  - Complexity & stack bound: <verified>
  - Mutant arms product site & anti-cheat: <verified>
  - Isolated lane paths & no placeholders: <verified>

REPORT (<= 25 lines; first line `LANE <lane> <ID>`):
  - Agents (model/effort, start-end UTC)
  - Files changed (diff --stat) + clean-restore sha256 per mutated file
  - RED output (exact lines)
  - GREEN outputs (all compilers, sanitizer, golden, integration)
  - Mutants (each FAIL + clean-restore cmp/sha256 proof)
  - Perf gate lines verbatim
  - Every drift or deviation verbatim (or `drift: none`)
  Remove staged files on report, update implementer state/handoff, then wait.
```

---

## 2. Read-Only PROBE Brief template (measure before designing / audit reproduction)

Use whenever design needs dynamic ground truth (AST dumps, counts, failing shapes, interleaved A/B perf, ablations, audit reproductions) without building in the design session or editing lane source files.

```text
TASK BRIEF from @design, the lead of this project (self-contained).

ROLES / WHO YOU ARE / FIRST / STATE NOW / LANE: <same header structure; read-only scratch probe>
TASK PROBE-<ID>: <exact question being measured>
TICKET: <ticket-id or none (pre-brief probe)>
AGENTS: probe agent: <fast-model>/low (10-minute cap, read-only on repo sources)

RULES:
  - ZERO edits to tracked repository files (assert `diff` empty at end).
  - Copy any modified scratch sources / driver into `build/probe-<ID>/` ONLY.
  - Run under timeout + memory cap; capture output to file, then echo EXIT=$?.

COMMANDS:
  <exact scratch copy, build, and probe/ablation commands verbatim>

REPORT (<= 20 lines; first line `PROBE-<ID>`):
  - Exact setup (base commit, compiler flags, input fixture)
  - Verbatim measured outputs (no paraphrasing, no rounding)
  - Confirmation that repo working copy diff is empty
  Then wait.
```

---

## 3. Wave-Level LAND-VERIFY Brief template

Run on the exact combined `main` tip after linearly landing one or more lanes (never written from memory — copy exact command invocations from the landed briefs).

```text
TASK BRIEF from @design, the lead of this project (self-contained).

ROLES / WHO YOU ARE / FIRST / STATE NOW: <verify exact landed main tip commit <hash>>
TASK LAND-VERIFY-<WAVE>: verify combined tip <commit-hash>
AGENTS: verify agent: <fast-model>/low (10-minute cap) + perf agent: <fast-model>/low (quiet host)

RULES:
  - Read-only verification on commit <commit-hash>; ZERO source edits.
  - Delete old binaries before building.
  - Verify commit hash matches <commit-hash> and VCS status shows zero conflicts/divergence.

COMMANDS (exact invocations copied from landed lane briefs):
  1. Clean full build (all compilers + sanitizer) -> 0 warnings
  2. Full unit test suites (all compilers + sanitizer) -> exact expected count <N>/<N>
  3. Full golden + integration + differential/oracle suites -> exact expected lines
  4. Scoped static hygiene checks (zero disallowed `default:`, `nm` inline gate, `-fstack-usage` gate)
  5. Quiet-host tip perf baselines (all benchmarks, median of >=2 runs) + wave-start cumulative delta

REPORT (<= 25 lines; first line `LAND-VERIFY-<WAVE> <commit-hash>`):
  - Commit verified, build warnings, test counts, golden/oracle lines, hygiene checks, fresh tip perf rows + wave delta
  Then wait.
```

---

## 4. Sizing and model-tier rubric

- **Sizing:** If one agent cannot finish RED -> GREEN -> build -> tests inside 10 minutes, split into `-a`, `-b`, `-c` BEFORE dispatch.
- **Model & effort selection:**
  - **Fast / low:** exact mechanical scripts, data files, `PROBE`s, `LAND-VERIFY`, perf runs, 1-line additions.
  - **Mid / medium:** production code + tests from a tight contract and ruled names.
  - **Strongest / high:** persistent designer, hard root-cause debugging, multi-file invariants, and the mandatory escalation retry after two failed attempts.
- **Playbook tier drop:** Once an expensive task's procedure is verified and frozen as a playbook/template, subsequent repetitions drop one model tier.
