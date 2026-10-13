# vic's own Claude Code tooling, ported verbatim from frodo ~/.claude:
# vic-* subagents (tiered haiku/sonnet/opus), vic skills, global CLAUDE.md.
# Copies live beside this file; edit them here, never in ~/.claude.
{
  vic.ai.homeManager =
    { lib, ... }:
    let
      byName = dir: f: lib.mapAttrs' f (builtins.readDir dir);
    in
    {
      programs.claude-code = {
        agents = byName ./agents (
          file: _: lib.nameValuePair (lib.removeSuffix ".md" file) ./agents/${file}
        );
        skills = byName ./skills (name: _: lib.nameValuePair name ./skills/${name});
        context = ./memory/CLAUDE.md;
      };
      # CLAUDE.md imports it with `@RTK.md`.
      home.file.".claude/RTK.md".source = ./memory/RTK.md;
    };
}
