## Local deltas - these override the operating memory below

The operating memory comes from `github:sini/genie-agent` (`operating-memory/`), written for sini's
machine. It is installed as the `operating-memory` skill: a `[[slug]]` link names a file under
`~/.claude/skills/operating-memory/`. On vic's machines:

- **The owner is vic.** "Owner" in any file means vic.
- **The shell is fish**, not zsh or bash. Heredocs do not work. The zsh facts do not apply; the
  general rules (read exit status unpiped, carry the count unit) still apply.
- **VCS is jj**, never git. **Never commit or push without vic's explicit permission.** A dispatched
  agent never runs jj or git; the supervisor lands (`/workspace`). Read every "commit", "push" or
  "land" step as: report the changed paths to the supervisor.
- **The memory bank is quipu** (`mcp__plugin_hm_quipu__*`), not hindsight. Read "recall" as
  `quipu_context` / `quipu_search_nodes` / `quipu_search_facts`; read "retain" as
  `quipu_resolve_entity`, then `quipu_knot` or `quipu_episode`.
- **The tracker is br** where the project has `.beads/`. sini's `STATUS/*.sh` scripts exist only in
  den-ag-design.
- **Paths:** ignore `/home/sini/...`. Repositories are under `~/hk/`.
- **vic's rules outrank this memory** (`/vic`, `/dispatch`, `/supervisor`). Where they conflict, name
  the conflict in one line and take vic's rule.
