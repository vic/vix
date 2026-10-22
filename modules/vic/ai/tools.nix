# Agent CLIs from numtide/llm-agents.nix, with their Claude Code wiring.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.ai-tools = {
    at = ren.aspects.vic-headless;
    claude-allow = { ... }: [
      "Bash(br *)"
      "Bash(codegraph *)"
      "Bash(openspec *)"
      "Bash(openspecui *)"
    ];
    git-ignores = { ... }: [
      ".codegraph"
      "/AGENTS.md"
    ];
    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      let
        llm = (vix.perSystem pkgs inputs.llm-agents).packages;

        calldiff = pkgs.writeShellApplication {
          name = "calldiff";
          runtimeInputs = [ pkgs.nodejs ];
          text = ''exec npx --yes calldiff "$@"'';
        };

        # `openspec init` run in a sandbox to render its workflow skills statically.
        openspecSkills = pkgs.runCommand "openspec-skills" { nativeBuildInputs = [ llm.openspec ]; } ''
          export HOME=$TMPDIR/home XDG_CONFIG_HOME=$TMPDIR/xdg
          export CI=true OPENSPEC_TELEMETRY=0 OPENSPEC_NO_COMPLETIONS=1 DO_NOT_TRACK=1
          mkdir -p $HOME $XDG_CONFIG_HOME/openspec $TMPDIR/proj $out
          cat > $XDG_CONFIG_HOME/openspec/config.json <<'JSON'
          {
            "featureFlags": {},
            "profile": "custom",
            "delivery": "skills",
            "workflows": ["propose","explore","new","continue","apply","update","ff","sync","archive","bulk-archive","verify","onboard"]
          }
          JSON
          cd $TMPDIR/proj
          openspec init --tools claude --force --profile custom </dev/null
          cp -r .claude/skills/* $out/
        '';
      in
      {
        home.packages = [
          llm.rtk
          llm.hunk
          llm.beads-rust
          llm.beads-viewer
          llm.codegraph
          llm.openspec
          calldiff

          # Other agent harnesses sini runs beside Claude Code (installed, not configured).
          llm.crush
          llm.opencode
          llm.pi
          llm.antigravity-cli
          llm.hermes-agent
        ];

        programs.claude-code = {
          skills = {
            hunk-review = "${llm.hunk.src}/packages/hunk/skills/hunk-review";
          }
          // lib.mapAttrs (name: _: "${openspecSkills}/${name}") (builtins.readDir openspecSkills);

          mcpServers.codegraph = {
            type = "stdio";
            command = lib.getExe' llm.codegraph "codegraph";
            args = [
              "serve"
              "--mcp"
            ];
          };

          settings = {
            # br resolves its workspace from cwd unless pinned; point this at your tracker:
            # env.BEADS_DIR = "/path/to/tracker-repo/.beads";

            # Rewrites eligible Bash commands to `rtk <cmd>`, compressing their
            # output before it reaches the model (what `rtk init -g --hook-only` installs).
            hooks.PreToolUse = [
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = "rtk hook claude";
                  }
                ];
              }
            ];
          };
        };

      };
  };
}
