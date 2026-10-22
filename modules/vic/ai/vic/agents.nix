# vic's own Claude Code tooling, ported verbatim from frodo ~/.claude:
# vic-* subagents (tiered haiku/sonnet/opus), vic skills, global CLAUDE.md.
# Copies live beside this file; edit them here, never in ~/.claude.
{
  ren,
  ...
}:
{
  ren.aspects.ai-vic-agents = {
    at = ren.aspects.vic-headless;
    homeManager =
      { lib, ... }:
      let
        byName = dir: f: lib.mapAttrs' f (builtins.readDir dir);
        # `tools:` is a closed allowlist; quipu is mandatory, so every agent gets it.
        quipuTools = lib.concatStringsSep ", " (import ../_quipu.nix).tools;
        withQuipu =
          file:
          builtins.replaceStrings [ "\ntools: " ] [ "\ntools: ${quipuTools}, " ] (builtins.readFile file);
      in
      {
        programs.claude-code = {
          agents = byName ./agents (
            file: _: lib.nameValuePair (lib.removeSuffix ".md" file) (withQuipu ./agents/${file})
          );
          skills = byName ./skills (name: _: lib.nameValuePair name ./skills/${name});
          context = ./memory/CLAUDE.md;
        };
        # CLAUDE.md imports it with `@RTK.md`.
        home.file.".claude/RTK.md".source = ./memory/RTK.md;
      };
  };
}
