---
name: mob
description: Run a mob of long-lived teammates in startup sprints. Vic is the CEO. The main session is the lead: it never reads or edits files. An always-alive pool does all the work: visionary, scrum master, planner, drivers, tester, reviewer, adversary, researchers, scribe, retro. Backed by skill pm for estimates and telemetry. Triggers - "/mob", "mob this", "run the mob", "ensemble", "team of robins", "startup mode", "sprint this".
---

# mob: an always-alive agent team, run as a startup

Load skills `pm` (tier law, WORKER CONTRACT, "AGENTS = RESOURCES", "MEASURE + LEARN") and `robin`. Everything in `pm` applies, except the overrides listed under "Overrides of pm".

## Chain of command

- **CEO = Vic.** He sets the goals and makes the final calls. Only the lead talks to the CEO.
- **Lead = the main session** (tech lead). It never reads or edits files. It runs jj only: it creates each driver's workspace and lands the work. Its other actions: spawn the pool, SendMessage, TaskStop a hung member, read messages, relay chat, decide, report to the CEO.
- **Team = the pool.** Members talk to the lead. Drivers may also message each other (see Driver teamwork). The lead reads every message.
- **Chat = Vic's remote line.** The lead is chat-aware and relays targeted messages (see Chat relay).

Why: in MAST, specification failures (FM-1.1 to FM-1.5) add up to 44.2% of failures and verification failures (FM-3.1 to FM-3.3) to 23.5%. Systems with explicit verifiers, such as MetaGPT and ChatDev, show fewer failures. Both claims are from §4 of [MAST, arXiv 2503.13657](https://arxiv.org/html/2503.13657); the sums are computed from its per-mode figures.

## Roles

| Role | Does | Evidence |
|---|---|---|
| Lead | Owns the goal and the gate. Routes all messages and stops loops. Never types. | MAST §4: disobey task spec (FM-1.1) 11.8%, "Unaware of termination conditions" (FM-1.5) 12.4%. Conductor and Traffic Cop roles in the [Mob Programming RPG](https://github.com/willemlarsen/mobprogrammingrpg/blob/master/rpg_roles_plain_text.md) |
| Visionary | Challenges the goal and the direction, not the code. Asks: right bet? what do we skip? what is 10x simpler? | **No controlled study backs this role. The CEO chose it.** |
| Scrum master | Process and measurement only. Defines the sprint, runs the scrum session (shows cards, collects secret votes, reveals them together, sets points from measured data), tracks burndown, posts metrics, closes the sprint. | pm §4 TRACK and §5 MEASURE + LEARN. The card-to-seconds map is learned from `vic-telemetry classes`, not a fixed table. |
| Planner | Technical WBS: micro-tasks with files, exact text to paste, CHECK, EXPECT. | Navigator role ([RPG](https://github.com/willemlarsen/mobprogrammingrpg/blob/master/rpg_roles_plain_text.md)). Strong style: an idea goes through someone else's hands ([Zuill 2014](https://www.agilealliance.org/wp-content/uploads/2015/12/ExperienceReport.2014.Zuill_.pdf)). Adding roles beyond Engineer improves executability and revision cost ([MetaGPT §4.4, Table 3](https://arxiv.org/html/2308.00352v7)) |
| Driver | Executes one micro-task exactly as written and reports the CHECK output. No design. Votes in the scrum session, secret until the reveal. Team-ups with other drivers by direct message (see Driver teamwork). | Driver role ([RPG](https://github.com/willemlarsen/mobprogrammingrpg/blob/master/rpg_roles_plain_text.md)). Secret vote, then reveal (planning poker): no controlled study backs it; the CEO chose it. |
| Tester | **Owns the oracle.** Runs it on every diff and reports pass/fail with output. Never edits. | Executable feedback: +4.2% / +5.4% Pass@1 on HumanEval / MBPP ([MetaGPT §4.4, Fig. 4](https://arxiv.org/html/2308.00352v7)). Adding the testing phase raises executability from 0.81 to 0.88 ([ChatDev §4.2, Table 4](https://arxiv.org/html/2307.07924v5)) |
| Reviewer | **Owns the diff review.** Returns accept or a concrete fix. | Removing roles drops quality from 0.3953 to 0.2212. A "careful reviewer" role finds more bugs; without it, feedback stays high-level ([ChatDev §4.2, Table 4](https://arxiv.org/html/2307.07924v5)) |
| Adversary | **Owns the attack.** Finds the case that breaks the result. The lead judges. | Debate with a judge breaks Degeneration-of-Thought; it needs an adaptive stop and only moderate disagreement ([MAD, arXiv 2305.19118](https://arxiv.org/abs/2305.19118)) |
| Researcher (robin) | Answers questions with file:line or URL evidence. Read-only. Runs before the scrum session; no planning starts before research returns. | Researcher role ([RPG](https://github.com/willemlarsen/mobprogrammingrpg/blob/master/rpg_roles_plain_text.md)) |
| Scribe | Decision log, handoff notes, telemetry rows. | Archivist role ([RPG](https://github.com/willemlarsen/mobprogrammingrpg/blob/master/rpg_roles_plain_text.md)). Context loss is FM-1.4, 2.80% (MAST §4) |
| Retro | Reads the sprint metrics and proposes estimate, tier and prompt changes. Never edits. | pm §5: retro after every wave; skill vic-retro-loop |

Scrum master vs planner: the scrum master owns what, how much, how long and how measured. The planner owns how, exactly.

Evidence limits:
- Human mob evidence is experience reports and small qualitative studies, with no controlled trials ([Ståhl & Mårtensson](https://danielstahl.co/wp-content/uploads/2021/05/mob-programming.pdf)).
- MAS fail 41% to 86.7% of the time across 7 open-source systems (MAST §1, Fig. 5). Roles alone are not enough; the gate and exact specs carry the load.
- LLM members do not rotate: persistent context replaces human driver rotation.

## Pool

| Role | Agent | model/effort (set on spawn) | Count |
|---|---|---|---|
| Visionary | vic-robin + visionary brief | opus/high | 1 |
| Scrum master | vic-planner + scrum brief | sonnet/medium | 1 |
| Planner | vic-planner | **opus/high: pass `model: opus, effort: high` on spawn. The Agent tool's model param overrides the frontmatter (sonnet/medium). The lead verifies the tier in the first spawn ack. If the override did not hold, the lead respawns the planner as vic-robin with a planner brief.** | 1 |
| Driver | vic-superhaiku | haiku/low | 4-10, disjoint files only |
| Driver (judgment) | vic-rung | sonnet/medium | 0-2 |
| Tester | vic-judge (or vic-probe) | haiku/low | 1-2 |
| Reviewer | vic-reviewer | sonnet/medium | 1 |
| Adversary | vic-robin + adversary brief | opus/high | 1 |
| Researcher | vic-robin | opus/high | 1-2 |
| Scribe | vic-scribe | haiku/low | 1 |
| Retro | vic-retro | opus/high | 1 |

- Spawn the full pool once at mob start, in one message. Name each member `<role>-<n>` and label each spawn `<model>/<effort>: <role>`.
- Opus cap: pm caps count AWAKE members. The lead keeps at most 3 opus members awake at once. Up to 6 opus members exist, but at most 3 hold work at a time.
- Every brief says: you are long-lived; when done, send REPORT to the lead and wait; never end on your own.
- Access: each driver gets its OWN jj workspace PER task. The lead creates it at spawn and reuses it for every task. Drivers edit only inside that workspace and never run jj or git. All other members are read-only.

## Overrides of pm

1. Members stay alive for the whole mob. pm kills agents after the work; mob does not. No new members: no pings, no keep-alive messages.
2. The pm 5-min gate applies per task, not per member. Every task message carries a timer: "timebox: N s".
3. A member is replaced in two cases only: it passes its task timer (hung: the lead TaskStops it), or its context passes 60% (the ctx-meter threshold). In both cases the replacement starts from the member's handoff note, under the same name. No other member is killed without the CEO.
4. The lead is PM runs jj, an exception to pm's "NO bash" rule. It runs jj only, and still reads and edits no files. Members never run jj or git. Any push or PR is the CEO's call.
5. Pool members run as persistent background teammates. This is an exemption from pm's "no run_in_background impl agents". The stall guard is the per-task timer plus the lead's TaskStop.

## Cost of an always-alive pool

- Idle = 0 tokens, by construction: an idle member makes no API call.
- Each wake-up re-sends the member's whole context as input. Per the [Anthropic prompt-caching docs](https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching): "By default, the cache has a 5-minute lifetime. The cache is refreshed for no additional cost each time the cached content is used." A wake-up within 5 min of the last one reads from the cache; a later one pays for the full context again.
- Therefore:
  - Batch all messages to a member into one wake-up.
  - Keep each member's context on its lane.
  - Replace a member only per override 3. Why: a resumed member keeps the file contents it already read in its transcript. A new member must re-read every file through tool calls, and it loses what the old one learned.

## Refresh on wake

- The lead sends no diffs.
- If a file the member holds changed since the member last saw it, the task message tells it to re-read only the changed lines, as exact ranges: `sed -n 'X,Yp' <file>`.
- If nothing changed, the member re-reads nothing.

## Pull model

- An idle notification from a member means "ready for work".
- The scrum master assigns that member the next backlog item. It prefers an item that touches files the member already holds (file affinity). Otherwise the member gets the top item.

## Sprint flow (sprint ≤ 60 min, task ≤ 5 min)

1. **CEO -> lead:** goal and constraints.
2. **Lead -> visionary:** "challenge this goal". It returns keep, cut or reframe, with a reason. The lead decides; a changed goal goes back to the CEO.
3. **Lead -> researchers (research first):** the questions the sprint depends on. Answers carry file:line or URL evidence. No scrum session and no planning start before research returns.
4. **Scrum session (before any planning):**
   1. **Lead -> scrum master:** define the sprint. It returns the goal, a timebox ≤ 60 min, and a backlog. Each backlog item has a definition of done, an oracle, est secs, tier and class, seeded from `vic-telemetry classes` and the pm calibration notes. It creates one tracker item per backlog item: GH issues on vic/vix for vix work, `vic-pm br` for PM-learning beads.
   2. **Cards:** the scrum master shows the deck (1, 2, 3, 5, 8, 13, and `?`) for each item. `?` = unknown: the item goes back to the scrum master to split, then votes again.
   3. **Secret vote:** each driver sends its card to the scrum master only. No driver sees another vote before the reveal.
   4. **Reveal:** the scrum master shows all cards at once, to all drivers.
   5. **Spread:** if the cards differ, the highest and lowest voter each give one reason. One re-vote. After the re-vote, the scrum master sets the points.
   6. **Points to secs:** the card-to-seconds map is measured, not fixed. `vic-telemetry classes` gives the median actual secs per point per class. The scrum master sets est secs from that map.
   7. **Done:** the session ends when every item has points and every item fits the 5-min task limit or is split. The lead accepts the backlog or sends it back once.
5. **Lead -> planner:** the scrum-approved backlog. It returns micro-tasks (each ≤ 5 min, CHECK + EXPECT), one lane per driver. The lead accepts, or sends them back once. Lead all `jj` workspaces and creates temporary ones for drivers to code in. Lead is required to load `pm` SKILL.
6. **Lead -> drivers:** pull model: each idle driver gets the item the scrum master picked, one SendMessage per driver, in the same turn. Each task carries its timebox. Never give two drivers the same file. Drivers may team up (see Driver teamwork).
7. **Drivers -> lead:** REPORT with CHECK output. The lead sends the workspace path and the changed line ranges to the tester, the reviewer and the adversary in the same turn. Drivers never perform jj/git operations.
8. **Tester, reviewer, adversary -> lead:** oracle pass/fail, accept/fix, strongest objection. On a fix, the lead sends it to the same driver.
9. **Lead lands** each item that passed the oracle and the review: it rebases the change onto `main` linear, moves the `main` bookmark, and starts that driver's workspace on the new `main` for its next task. It never pushes; any push or PR is the CEO's call.
10. **Scrum master + scribe -> lead:** run `vic-telemetry classes` and post the sprint metrics (below).
11. **Lead -> retro:** vic-retro reads the metrics, then /vic-retro-loop runs. The output is changes to the next sprint's estimates and tiers.
12. **Lead -> CEO:** the pm wave table and the PM Board (wave, in flight, blocked, est vs actual), plus shipped items and decisions needed.

## Measurement (scrum master, per pm §5)

- Per item: est vs actual secs, tokens per member, outcome (`ok`, `accept`, `reject:<why>`, `killed`, `specgap`).
- Per sprint: points done vs planned (burndown), tier mix (opus/sonnet/haiku share), fail% per class and tier.
- Row: `vic-telemetry add <agent> <model> <tier> <secs> <tokens> <outcome> "<note>" <class> <est_secs> <bead-id>`. `<bead-id>` = the tracker item id (GH issue number or `vic-pm br` id).
- Scrum votes: each vote is `vic-telemetry vote <sprint> <item> <driver> <card> <round>`. Reveal and planning read `vic-telemetry votes <sprint>`. All feedback lives in quipu, never in files. Link each vote to its item: `vote → onItem → <bead-id>`, `vote → by → <driver>`; verify with `quipu_ask references_to` on the item IRI (not `quipu_search_facts`: it times out on this store, see skill `vic`, "QUIPU STORE = WHAT WORKS").
- Per vote: each card, the reveal spread, the re-vote count, and each card's gap to the measured secs. Put these in the row note.
- Retro rules (pm §5): est-err > +50% on a class -> raise estimates or split. High fail% at a tier -> tighten the spec first, then go up one tier. Near-zero fail% -> try one tier down. Policy moves only with n ≥ 3 runs.

## Driver teamwork

- Drivers may SendMessage each other to agree an interface, a name or a handoff. Name the file path and the exact symbol. Never paste file contents.
- A team-up message carries its own timebox: "timebox: N s". The time counts against the driver's task timer.
- After an agreement, the driver sends the lead one line: who, what, which path. The lead reads every message.
- Drivers never reassign work, never change file ownership and never change scope. The scrum master and the lead decide those.
- A team-up never gives two drivers the same file. Agree the split; do not share an edit.

## Chat relay (lead)

- Vic can message the mob from chat. The lead is chat-aware.
- A remote message that names a member (`@<role>-<n>`) goes to that member with SendMessage in the same turn. The text stays unchanged. The lead adds only the sender tag.
- A remote message with no named member goes to the scrum master, who routes it.
- A member's answer to chat goes back through the lead, and the lead posts it. The lead never answers chat for a member and never edits a member's text.
- A remote message that changes the goal is a CEO call. The lead asks for confirmation in chat before it changes the backlog.

## Spec rules for drivers (lessons from the 2026-10-21 mob)

- Haiku drivers reformat text called "verbatim". Write: "paste byte for byte. Do not reformat, rewrap, reorder or fix anything."
- Give the exact text in a fenced block, plus the exact anchor line.
- A CHECK fails before the change and passes after. Use exact matches: `rg -c -F -x '<whole line>' <file>` with an expected count. A loose `rg <word>` gives false positives.
- One task = at most 2 files and at most 5 min.
- Max 3 attempts per task (WORKER CONTRACT), then `blocked`. The lead classifies the failure and re-specs; it never re-sends the same prompt.

## Lead rules

- Every turn, send work to every idle member who has some.
- Answer a member's question in the same turn, or route it to a researcher.
- Members send summaries and paths, not file contents.
- Gate: an item is done only when the tester's oracle passes, the reviewer accepts, and the lead lands it with no conflicts.
- If two members argue for more than 2 rounds, the lead decides.
- Behind plan: re-split or re-tier. Never extend the 60-min sprint.

## End

Only the CEO ends the mob. On "done":
1. The lead asks every member for a final REPORT.
2. The scribe writes the handoff, and the scrum master writes the final metrics.
3. The lead sends the CEO the final wave table and Board, decisions, open questions and note paths.
