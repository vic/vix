# Plain (non-plugin) Claude Code skills: the local ones under ./skills, plus
# gstack and task-observer from upstream.
{
  inputs,
  ren,
  ...
}:
{

  ren.aspects.ai-skills = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        genie-agent = {
          url = "github:sini/genie-agent/4c1ade83da5b80d080ee2051e5bf8f70dd5ad7f7";
          flake = false;
        };
        gstack = {
          url = "github:garrytan/gstack/953a62a72412ba2ec430972226b7b3a999839df5";
          flake = false;
        };
        one-skill-to-rule-them-all = {
          url = "github:rebelytics/one-skill-to-rule-them-all/56e890712273ce231b478adc56ee2eb81101c3d6";
          flake = false;
        };
      };
    git-ignores = { ... }: [ ".gstack/" ];
    claude-allow = { ... }: [
      "Bash(bun run *)"
      "Bash(bun *)"
      "Bash(~/.claude/skills/*)"
    ];
    homeManager =
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
        };

      };
  };
}
