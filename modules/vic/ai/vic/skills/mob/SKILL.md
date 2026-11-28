---
name: mob
description: Run an always-alive mob of specialist teammates in <=60-min startup sprints (ALL projects) — CEO=owner, Lead=main session (never edits files; owns jj + gates), pool of visionary, scrum master, planner, drivers, tester, reviewer, adversary, researchers, scribe, retro. Enforces experiment/evidence gating before coding, <=5-min driver tasks, clean-restore verification, and prompt-cache discipline. Triggers — "/mob", "mob this", "run the mob", "startup mode", "sprint this".
---

# MOB — Always-Alive Specialist Team in `<= 60`-min Sprints (vic, global)

**Stack:** `/vic-stack` · `/pm` (tier law, WORKER CONTRACT, telemetry, `gebed_report`) · `/robin` · `/pie` (`P -> I -> E`) · `/probes` (experiment gate) · `/oracle` · `/jj` · `/vic-retro-loop`.

Everything in `/pm` applies except the explicit overrides below.

**Assets in this skill:**
- `references/role-briefs.md` — concrete copy-paste spawn briefs for Visionary, Scrum Master, Planner, Driver, Tester, Reviewer, Adversary, Researcher, Scribe, and Retro (with WORKER CONTRACT + evidence gate built in).
- `references/session-mob.md` — multi-session IRCC room mob protocol (`&vic`, 5-min standup cron, leader rulings, PR reviews, CI checks).
- `scripts/sprint-metrics.sh` — computes accurate sprint burndown, outcome-based `fail%` (avoiding the `vic-telemetry` hook bug), and vote spread summary.

---

## 1. Chain of Command & Roles

- **CEO = Owner:** sets goals and final calls; only Lead talks to CEO.
- **Lead = Main Session:** never reads/edits production code; owns `jj` workspaces + linear landings, spawns pool, routes messages, kills hung members, enforces gates, reports to CEO.
- **Pool (spawned once at mob start, named `<role>-<n>`, labeled `<model>/<effort>: <role>`):**
  - `visionary` (`vic-robin`, `opus/high`, 1): challenges goal/direction (*what do we skip? what is 10x simpler?*).
  - `researcher` (`vic-robin`, `opus/high`, 1–2): read-only `file:line`/URL answers BEFORE scrum/planning.
  - `scrum-master` (`vic-planner`, `sonnet/med`, 1): sprint backlog, secret planning-poker reveal, telemetry-calibrated points -> seconds, burndown, `gebed_report` / `vic-telemetry`.
  - `planner` (`vic-planner`, `opus/high` explicit — verify tier in ack, 1): micro-tasks (`<= 5 min`, `<= 2` files, exact anchors, `CHECK` + `EXPECT` + mutant).
  - `driver` (`vic-superhaiku` `haiku/low` 4–10, or `vic-rung` `sonnet/med` 0–2): executes exact micro-task in its own `jj` workspace; zero design, zero `jj`/`git`.
  - `tester` (`vic-judge` / `vic-probe`, `haiku/low`, 1–2): owns the oracle + mutant + clean-restore SHA check; never edits.
  - `reviewer` (`vic-reviewer`, `sonnet/med`, 1): diff review (`accept` or concrete fix).
  - `adversary` (`vic-robin`, `opus/high`, 1): attacks soundness/edge cases; Lead judges (max 2 debate rounds).
  - `scribe` (`vic-scribe`, `haiku/low`, 1): decision log, `HANDOFF.md`, telemetry rows.
  - `retro` (`vic-retro`, `opus/high`, 1): sprint-end `/vic-retro-loop` proposals; never edits.
- **Opus cap:** At most 3 opus members awake/working simultaneously.

---

## 2. Overrides of `/pm` & Prompt-Cache Economics

1. Members stay alive for the sprint (idle = 0 tokens; wake-ups within 5 min hit prompt cache -> batch messages per wake-up, preserve file affinity, re-read only changed line ranges via `sed -n 'X,Yp'`).
2. Per-task `<= 5 min` timebox (`timebox: 300s`) applies per task, not per member. Replace a member ONLY when it exceeds its task timer (`TaskStop`) OR hits `>= 60%` ctx (replace from its handoff note under the same name).
3. Lead runs `jj` (exception to `/pm` zero-Bash) for workspace setup and linear landing only; still reads/edits ZERO repo files.
4. Persistent background pool members are exempt from `/pm`'s no-background rule because per-task timers + Lead `TaskStop` guard against stalls.

---

## 3. Sprint Flow (`<= 60 min`, every driver task `<= 5 min`)

1. **CEO -> Lead:** goal + measurable exit bar.
2. **Visionary:** challenge goal (`keep` / `cut` / `reframe`).
3. **Researchers (read-only):** settle open questions with `file:line`/URL citations.
4. **Experiment / Evidence Gate (`/probes` + `evidence-gate.sh`):** before planning perf or architectural bets, run a throwaway release ablation stub (`verdict: STUB` -> `PASS`, or `FAIL` = drop item immediately with zero driver code written).
5. **Scrum Session:** backlog items with oracle + `gebed` bead + secret planning-poker votes (`1,2,3,5,8,13,?`; `?` or `> 5 min` MUST split) -> reveal via `vic-telemetry vote/votes` -> calibrate points-to-seconds from historical telemetry.
6. **Planner:** produce `<= 5 min`, `<= 2`-file micro-tasks (exact byte-for-byte anchors, `rg -c -F -x` checks, armed mutants, disjoint files).
7. **Pull-Model Execution:** Lead creates per-driver `jj` workspaces and assigns disjoint items (preferring file affinity). Drivers may team up via direct `SendMessage` on interfaces (counted in task timer; zero shared file edits; 1-line summary to Lead).
8. **Parallel Gate (Tester + Reviewer + Adversary):** Driver returns `REPORT` -> Lead sends workspace path + changed line ranges to Tester (oracle + mutant + clean-restore SHA), Reviewer (diff check), and Adversary (attack) in ONE turn.
9. **Linear Land:** Lead rebases/squashes passing items linearly onto `main`, refreshes driver workspace onto new `main`, never pushes without CEO.
10. **Sprint Close:** Scrum Master + Scribe run `scripts/sprint-metrics.sh` + `gebed_report` -> Retro runs `/vic-retro-loop` -> Lead reports wave table, shipped items, and decisions to CEO. (Behind plan -> re-split or re-tier; NEVER extend the 60-min sprint.)
