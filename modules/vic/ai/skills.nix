# Plain (non-plugin) Claude Code skills: the local ones under ./skills, plus
# gstack and task-observer from upstream.
{ inputs, ... }:
{
  flake-file.inputs = {
    gstack = {
      url = "github:garrytan/gstack";
      flake = false;
    };
    one-skill-to-rule-them-all = {
      url = "github:rebelytics/one-skill-to-rule-them-all";
      flake = false;
    };
  };

  vic.ai.homeManager =
    { lib, pkgs, ... }:
    let
      # every subdirectory holding a SKILL.md, by name
      skillDirs =
        dir:
        lib.mapAttrs (name: _: "${dir}/${name}") (
          lib.filterAttrs (
            name: type: type == "directory" && builtins.pathExists "${dir}/${name}/SKILL.md"
          ) (builtins.readDir dir)
        );
    in
    {
      home.packages = [
        pkgs.bun # gstack runtime
        pkgs.mermaid-cli # diagram-mermaid-render
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
          };

        settings.permissions.allow = [
          "Bash(bun run *)"
          "Bash(bun *)"
          "Bash(~/.claude/skills/*)"
        ];
      };

      programs.git.ignores = [ ".gstack/" ];
    };
}
