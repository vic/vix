# lessons by skill / agent (harvested 2026-10-21)

## oracle
- suite-green != rule-fired; validate fix by per-class counter >> 0, not tally · n=1 · src:dnx/gate-triage.md
- suite w/ feature disabled passed silently; probe counters before "validated" · n=1 · src:dnx/track-perf.md
- run mutant even when green; survival = missing oracle · n=2 · src:viejo/state.md, otro/state.md
- rung gate = match vs reference impl + mutant that must fire · n=1 · src:pnx/HANDOFF.md
- absence/zero claim needs positive control w/ same predicate+population; zero control = broken instrument · n=3 · src:quipu/ledger, viejo/state.md, otro/state.md
- confirming re-run must differ on suspect step; arms sharing it prove nothing · n=1 · src:quipu/ledger
- error-observable test: expected refusal must differ buggy vs fixed; "it throws" not enough · n=1 · src:quipu/ledger
- parity claim needs negative control (change input, output must differ) · n=1 · src:quipu/ledger
- name property each review class protects + find pinning test; none = finding · n=1 · src:quipu/ledger
- own fix can regress sibling: re-run all prior gates after each change · n=1 · src:quipu/ledger
- error text w/ order-dependent content is not stable oracle · n=1 · src:pnx/HANDOFF.md
- measure interaction/op count, not wall, for correctness gates · n=1 · src:otro/discipline.md

## probes / vic-probe
- haiku probe runs EXACT cmds, pastes verbatim; thinkers never run cmds inline · n=2 · src:dnx/effort.md, dnx3/discipline.md
- probe output = claim; probe summarized instead of pasting, leak caught only by re-grep · n=2 · src:misc/state.md, dnx3/discipline.md
- agent-built harness returned 0/0 on files w/ proven tests: positive control MANDATORY · n=2 · src:viejo/state.md, otro/state.md
- census -> classify -> route; census table + class counts + diff vs prior = DONE · n=1 · src:dnx/gate-triage.md
- probe-first: stale summary claim ("is stub"); empirical check before trusting · n=2 · src:otro/state.md, viejo/state.md
- PM leak scan printed CLEAN w/ unarmed control; arm on known-dirty input first · n=1 · src:quipu/ledger

## ensemble / judge
- cite judges as k=5 haiku + mechanical filter: cheap, effective · n=1 · src:pnx/state.md
- adversarial quorum (3 opus personas, each verified vs source) for design calls · n=2 · src:denren/quorum-verdict.md, otro/state.md
- 27-agent antagonist quorum falsified plan, saved building wrong thing · n=1 · src:otro/state.md
- root cause confirmed by 2 independent agents (flip table + raw trace) · n=1 · src:denren/stack-overflow-where.md

## superhaiku / readers / scribe
- haiku readers do recon -> files; sonnet builders consume; opus verifies · n=3 · src:rev/state.md, misc/state.md, pnx/state.md
- haiku scribe owns HANDOFF/state upkeep · n=1 · src:rev/state.md
- haiku-tier probe/scribe refuse to write report .md; use general agent w/ explicit auth · n=2 · src:genie/HANDOFF.md, vic-history/memory
- ls every "written" file after agent claims write · n=3 · src:genie/HANDOFF.md, quipu/ledger, vic-history/memory

## workspace
- each editing agent own jj ws; agents never touch jj/git · n=4 · src:dnx3/discipline.md, viejo/discipline.md, otro/discipline.md, rev/state.md
- agents still tried git (rm denied, diff ran) despite rule: enforce by permission, not prompt · n=1 · src:denren/HANDOFF.md
- ws agents cannot see vic docs (separate checkout): pass absolute paths · n=1 · src:dnx/jj-land-dance.md
- ws commit descriptions + salvage lists go stale; rg key symbols vs main before porting (4/4 already present) · n=2 · src:viejo/state.md, otro/state.md
- audit stale ws w/ revset before forget (32 stale seen) · n=1 · src:otro/state.md

## handoff
- HANDOFF.md rewritten each session w/ NEXT-CMD + FILES · n=1 · src:pnx/state.md
- HANDOFF header claiming COMPLETE = snapshot, not current; verify · n=2 · src:viejo/HANDOFF.md, otro/state.md
- HANDOFF main pointer stale 2/2 sessions: `jj log main` first · n=2 · src:viejo/state.md, otro/state.md
- write state/blockers to files; supervisor reads them · n=2 · src:vic-history/history.jsonl, dnx3/discipline.md

## ledger / lessons
- lesson = one incident; 2nd independent incident promotes to practice · n=1 · src:genie/Q13-lessons.md
- each lesson ends w/ imperative check (cmd or fixture); 9/26 lacked it · n=1 · src:genie/Q13-lessons.md
- state each rule once, cross-link; same rule in 3 files rots · n=1 · src:genie/Q13-lessons.md
- tool-behaviour notes need version + date + re-probe cmd · n=1 · src:genie/Q11-traps-harness.md
- index hook text must name symptom; vague hooks never trigger · n=1 · src:genie/Q11-traps-harness.md
- "derived/inferred" tagged items = hypotheses, not measurements · n=1 · src:genie/Q11-traps-harness.md
- search knowledge graph before writing; duplicate episode had to be retracted · n=1 · src:quipu/ledger
- index arm w/ MEMORY.md index: hit@1 0.986 vs 0.972 frontmatter-only (24 scenarios x3) · n=1 · src:genie/SCORE.md

## vic-rung
- one sonnet rung = one oracle-gated impl step, gated before next · n=3 · src:rev/state.md, pnx/state.md, dnx3/state.md
- ladder: each rung <=5 min, independently landable, oracle + negctl · n=1 · src:otro/error-nf-ladder.md
- spec header carries TIER + 1 rung + <=5 min kill · n=1 · src:otro/nfx-select-head-beta.md
- dead agent left clippy-red edits; finisher must run lint gate · n=1 · src:dnx/track-lean.md

## vic-hunter / isolate
- minrepro + flip table before hunt; hunter w/o minrepro burns · n=2 · src:dnx/gate-triage.md, denren/stack-overflow-where.md
- falsifications instrumented, bisected, byte-pristine reverted · n=1 · src:viejo/state.md
- root-cause by `cat -A` / raw bytes, not guess · n=1 · src:rev/state.md

## vic-reviewer / vic-lawyer
- reviewer audits every landed rung before accept · n=2 · src:dnx3/state.md, denren/state.md
- agent "green" != correct: read source for re-export, panic paths, band-aids; agent tests missed both twice · n=1 · src:denren/state.md
- check output vs harness, not agent's own tests · n=1 · src:denren/state.md
- decorative non-check (`var _ = x`) = test theater; replace w/ real test · n=1 · src:rev/state.md
- lawyer marks each claim VERIFIED/UNVERIFIED; feeds next design version · n=1 · src:pnx/HANDOFF.md
- lawyer cite-court decides forks; cites must be law docs · n=1 · src:otro/state.md
- review overclaimed 3 conflicts, gate showed 2 none: re-check conflict claims · n=1 · src:quipu/ledger

## vic-planner / agent defs
- planner told to use codegraph but frontmatter tools omitted it: agent cannot · n=1 · src:misc/verified-findings.md
- MCP tools deferred: subagent must ToolSearch-select schema; frontmatter grant alone insufficient · n=1 · src:misc/verified-findings.md
- test frontmatter change on ONE agent first; bad syntax can blank all tools · n=1 · src:misc/verified-findings.md

## deepwiki / research
- read paper summaries inline, no agent for it · n=1 · src:pnx/RULINGS.md
- design from current impls + recent work, not old thesis alone · n=1 · src:pnx/RULINGS.md

## quipu
- read ladder: `quipu_ask` catalog, then `quipu_query` SPARQL (label prefix, GROUP BY), then `quipu_context` max 3 · text search tools broken on this store · n=1 · src:quipu/live-2026-10-28
- as-of reads (`tx`, `valid_at` on `quipu_query`) answer "what did we know before X": ledger rows at tx 409 = 1, now 68 · use in retro and root cause · n=1 · src:quipu/live-2026-10-28
- empty / error / timeout = UNKNOWN; a zero claim needs a known-present control on the same query · n=2 · src:quipu/live-2026-10-28, quipu/docs/book/src/concepts/rule-answers.md:14
- refusal feedback converges agents in one revision when it names the fix; authority refusals need routing, not edits · n=1 · src:quipu/benchmark/census/agent/README.md:46-73
