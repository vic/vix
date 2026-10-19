# Plain (non-plugin) Claude Code skills: the local ones under ./skills, plus
# gstack and task-observer from upstream.
{
  ren,
  inputs,
  vicAt,
  mod,
  ...
}:
{

  ren.aspects.ai-skills = {
    at = vicAt.core;
    git-ignores = { ... }: [ ".gstack/" ];
    homeManager = mod (
      { lib, pkgs, ... }:
      let
        # every subdirectory holding a SKILL.md, by name
        skillDirs =
          dir:
          lib.mapAttrs (name: _: "${dir}/${name}") (
            lib.filterAttrs (name: type: type == "directory" && builtins.pathExists "${dir}/${name}/SKILL.md") (
              builtins.readDir dir
            )
          );
      in
      {
        home.packages = [
          pkgs.bun # gstack runtime
          pkgs.ast-grep # search-code-routing
          pkgs.ripgrep
        ];

        programs.claude-code = {
          skills =
            skillDirs ./skills
            // skillDirs inputs.gstack
            // {
              gstack = "${inputs.gstack}";
              task-observer = "${inputs.one-skill-to-rule-them-all}";
              # upstream has no SKILL.md: frontmatter + local deltas + upstream index become one
              operating-memory = pkgs.runCommand "operating-memory-skill" { } ''
                cp -r ${inputs.genie-agent}/operating-memory $out
                chmod u+w $out
                cat ${pkgs.writeText "frontmatter" ''
                  ---
                  name: operating-memory
                  description: Multi-agent operating memory (sini/genie-agent) - how to orchestrate, dispatch, gate, verify, land, and put decisions to the owner, with the measured traps behind each rule. Use when you orchestrate agents, write a dispatch brief, tier a decision, put a question to vic, record a ruling, review an artefact, or claim an absence or a count. Open only the files whose index line matches.
                  ---

                ''} ${./_local-deltas.md} $out/MEMORY.md > $out/SKILL.md
              '';
            };

          settings.permissions.allow = [
            "Bash(bun run *)"
            "Bash(bun *)"
            "Bash(~/.claude/skills/*)"
          ];
        };

      }
    );
  };
}
