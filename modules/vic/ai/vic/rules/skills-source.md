# Skills and agents: the vix repo is the source, ~/.claude is a copy

`~/.claude/{skills,agents,rules,CLAUDE.md}` are read-only symlinks into the nix store.
They are built from `~/hk/vix` and lag behind it until vic activates a new generation.

- To read a skill or agent, look in the repo first. Fall back to `~/.claude` only if the
  repo has no such file (upstream skills like gstack come from flake inputs).
- To change one, edit the repo file. An edit under `~/.claude` fails or is lost on the
  next activation. Never copy a skill into `~/.claude` to "fix" it.
- Repo paths, all under `~/hk/vix/modules/vic/ai/`:
  - skills: `vic/skills/<name>/`, `skills/<name>/`
  - agents: `vic/agents/<name>.md`, `agents/` (gen-* heads)
  - global `CLAUDE.md`: `vic/memory/CLAUDE.md`
  - rules: `vic/rules/<name>.md`, registered in `vic/hooks.nix`
- You may build, but never activate. After an edit, tell vic it needs an activation.
