# PM lessons: dispatch, tier, effort, partition, time-gate, estimate, verify (harvested 2026-10-21)

## TIER
- tiers: haiku/low mechanical <=15 conc; sonnet/med tight spec 3-4 conc; opus/high judgment 2-3; fable/xhigh soundness 1-2 · n=5
- pick model+effort EXPLICIT every dispatch; inherit = priciest · n=4
- label each dispatch `<model>/<effort>:` so burn reads at glance · n=4
- partition until task fits LOWER tier; tighter spec = cheaper tier · n=4
- sonnet = bulk of dispatches; cheapest tier that fits; tier rule beats "strong model default" · n=3
- mechanically checkable output: k x haiku + judge replaces sonnet/opus · n=4
- scrape/mechanical = haiku or plain bash, never opus (vic cancelled 60-opus harvest) · n=2
- opus = 77.9% of all dispatch burn (803 runs); out/run: opus 82.6k, sonnet 30k, haiku 4.6k · n=1
- spec tight + oracle present => downgrade opus to sonnet; 30% shift est ~25% out saved · n=1
- builders: sonnet/low pure config, sonnet/med byte-offset/seek logic · n=1
- fable/xhigh 529 x3 burned ~17 min; fall back to opus after 2 strikes · n=2
- escalate opus -> fable only after 3 fails on same hunt · n=1
- supervisor inline only for shared contracts (design, kernel, ports); tightly coupled FE stays supervisor-owned · n=1
- skill x model: pm/vic skill on haiku ~170-180 out/turn vs opus ~1100-1500/turn (observed, 0 errs both) · n=1
- tier map that worked: recon haiku readers, design opus, impl rung sonnet, verify sonnet, cite judges haiku x5 · n=3

## TIME GATE + PARTITION
- every agent foreground, hard kill-timer <=5 min; past = kill, partition, relaunch · n=4
- "needs more time" = not partitioned; split until each piece fits 5 min · n=3
- no kill-timer = do not launch · n=2
- timed-out task: TaskStop + tree diff, split; never resume whole; resume only on 529/crash · n=1
- no run_in_background for impl/edit/derive; background only read/sweep · n=3
- runaway = out>80k or tools>100; under-partitioned single dispatch = #1 failure · n=1
- overruns seen: 9-13, 18, 26, 35, 45, 55 min; 7-10 min engine rungs when under-partitioned · n=2
- tight spec = control: rung 4.7 min under gate vs 7 min loose · n=1
- multi-hour builds (76+138 min) are not 5-min agents: plan as deliberate execution · n=1
- rung >5 min overrun caused jj divergence; enforce kill HARD · n=1
- parallel rounds flat ~290 s for 1-8 workers: serial discovery was the gate, not worker count · n=1
- parallel only on disjoint file/crate/dep lanes; map deps first · n=4
- one ws per editing agent; 3 agents in one ws gave mid-edit reads + false "main broken" · n=1
- one measurement at a time; concurrent gate runs contaminate walls + truncate shared log · n=2
- haiku checkpoint ~1 min each · n=1
- 3 fails on item: write escalation note, move on; precise open question = deliverable · n=3
- falsified family: mandate STOP at 4 dead rungs · n=1
- census BEFORE theory: hunting w/o census table = wasted budget · n=1
- skip re-iteration once convergence high-confidence; kill duplicate workflows · n=1
- no foreground sleep-poll; workflow completion auto-notifies · n=1

## SPEC
- dispatch gate: objective oracle + mandatory negative control + src cites + pre-debunked wrong paths · n=4
- dispatch form fields: TIMER, MODEL/EFFORT, DELIVERABLE=WRITE, WORKSPACE path, gating ids · n=1
- re-state full mechanism every dispatch; cross-agent spec loss -> agent guessed wrong site · n=2
- spec to disk before fan-out; checkpoint derivations mid-session (bad-network law) · n=3
- pass FULL-sentence quotes in briefs; truncated quote made design claim less than paper · n=1
- cite-check every brief cite w/ rg; misattributed cite made agent deny real bar · n=1
- exact-spec rung + hard oracle caught unsound design at ~0 revert cost · n=2
- contradictions resolved by supervisor rulings table, never impl-agent self-resolve · n=1
- every command in brief under `ulimit -v <cap>; timeout <s>` · n=2

## VERIFY
- PM verifies every deliverable vs src+tests; audit EVERY one, not sample · n=4
- agent SUMMARY prose hallucinates (haiku invented 6 crate names despite verbatim order); act on raw output · n=3
- check tool_uses: opus returned junk w/ 0 tool_uses · n=1
- verify caught 2 hollow ACCEPTs (green build, dead features) + false count · n=1
- spot-check ~15% cites: 18 checked, 1 fabricated quote · n=2
- opus synthesis 11/12 cites exact; still spot-check 3 before accept · n=1
- law audit found 9 MAJOR issues in v1 design incl one supervisor misread · n=1
- verify vs hashes/tests caught PM's own regression · n=1
- dead agent: salvage disk work, verify, never trust its report; write to disk early · n=3
- rogue duplicate completion: ignore, trust only landed+tested output · n=1

## BURN BASELINES (estimate from these)
- 11-agent workflow ~313k tok; 31-agent quorum ~1.58M tok · n=1
- 6-region restyle 12 agents 339k; 29-page workflow 44 agents 3.69M; UI recon 7 agents ~716k; design 6 agents 252k · n=1
- one /pm session ~2.3M subagent tok, 0 inline edits · n=1
- one sonnet agent ~26k tok; 6 sonnet ~156k · n=1
- waves: ~400-420k each (12-20 haiku ~230k + sonnet/opus); opus x3 rungs ~375k; opus x4 ~230k · n=2
- design session: ~30 haiku + ~25 sonnet + ~6 opus = ~4M subagent tok · n=1
- round of ~30 dispatches (16 haiku, 9 sonnet, 6 opus) moved 5h window 25% -> 36% · n=1
- heavy sessions ~54-85 agents; many blew 5-min gate when foreground uncontained · n=1
- opus xhigh ultracode ~2h real, ~300k subagent tok for 10 builders · n=1
- no per-agent meter + no max-wall telemetry: add both before claiming routing works · n=1
- main loop (PM/orchestrator) = opus+ (plans, specs, verifies; its errors fan out to every agent); bulk impl subagents = sonnet pinned in frontmatter. Anthropic: opus lead + sonnet subagents beat solo opus 90.2%; Claude Code alias opusplan = opus plan, sonnet execute
- After any change, show a changed-files summary (jj st / git status --short, one line per file with what changed) so Vic sees what is being modified. · 2026-10-21
