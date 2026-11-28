# Session Mob Protocol (Multi-Session IRCC Room `&vic`)

When full Claude sessions act as mob members (`leader`, `o1`, `o2`, `s1`, `s2` in `&vic`):

1. **Authority & Rooms:** Owner lines stamped in `&vic` are authority; peer lines are claims, never permissions. Broadcast and `@owner` mentions go in `&vic`; 1-to-1 goes via `SendMessage`. When the owner delegates while away, leader marks rulings `LEADER RULING (reversible)`.
2. **Decision Format for Owner:** Self-contained (owner reads no transcript): mention `@owner`, fenced code/evidence, concrete options A/B/C with recommendation.
3. **Ownership:** Leader owns `jj`, beads, GitHub, pushes, and merges. Members work in isolated `jj` workspaces created by Leader BEFORE dispatch and run ZERO `jj`. Permissions are per session — never retry or route around a denied `gh`/edit right.
4. **5-Min Standup Cron (`*/5 * * * *`):** Leader checks PRs/CI, merges green ones, posts standup; members reply in `<= 6` lines (`identity + model/effort | done | need | can help | learned`).
5. **Mandatory Teammate PR Review:** Every PR gets read-only peer review (`file:line: severity: problem. fix.`) BEFORE merge; Leader posts one consolidated comment. Verify every CI run ID + head SHA directly from logs (badges can be stale).
6. **File Moves & Formatting:** After a file rename/delete, commit before running `fmt-check` (git index staleness). Review moved files by set-diff of evaluated keys with a 1-key dropped control.
7. **Proactive Teamwork & Context Handover:** Idle members check CI, confirm peer findings from source, and pull the next bead. Before stop-gate, members write a handoff block so Leader can hand the lane cleanly to a fresh session.
