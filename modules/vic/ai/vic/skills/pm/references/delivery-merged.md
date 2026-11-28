# Delivery = Merged (PR, Push, CI & Review Discipline)

1. **Done = merged on `main` with ALL checks green.** Pushed or "PR open" is not delivery.
2. **Verify every push:** Confirm `gh pr view <N> --json headRefOid` equals the local commit SHA. Never pipe a push into `grep` (hides `exit 124` timeouts). Show tail + `; echo EXIT=$?` on the same line.
3. **Hung SSH push:** Remove stale SSH control socket (`~/.ssh/socket-git@github.com:22`) and re-run under `timeout`.
4. **Immutable pushed bookmarks:** Never force-push or rebase an already-pushed PR branch — merge `main` forward.
5. **Flaky CI jobs (`exit 143`, no test failure):** Treat as evidence, not a shrug-and-rerun. Time the job, rule out concurrency cancel/OOM/runner loss, and fix the cause (e.g., cap parallel workers, add failure-only kernel/memory logs).
6. **Stale CI badges:** Read the actual run ID, head SHA, and raw CI log — never trust a badge or a room count without checking the log.
7. **Mandatory teammate review before merge:** One finding per line (`file:line: severity: problem. fix.`). Reviewers over-flag and under-check: verify every finding against source before acting. The authorized leader posts consolidated review comments and executes merges.
8. **Create workspaces BEFORE dispatching workers into them; lead edits zero repo files.**
