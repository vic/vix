# herdr: terminal multiplexer for coding agents (numtide/llm-agents.nix).
# Declarative equivalent of `herdr integration install claude` (v10), which
# cannot edit the home-manager owned settings.json.
{
  vicAt,
  mod,
  ...
}:
{
  ren.aspects.ai-herdr = {
    at = vicAt.headless;
    claude-allow = { ... }: [ "Bash(herdr *)" ];
    homeManager = mod (
      {
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        herdr = inputs'.llm-agents.packages.herdr;

        # upstream hook silently exits 0 when python3 is not on PATH
        hook = pkgs.writeShellScript "herdr-agent-state" ''
          PATH=${lib.makeBinPath [ pkgs.python3 ]}:$PATH
          exec sh ${herdr.src}/src/integration/assets/claude/herdr-agent-state.sh "$@"
        '';
      in
      {
        home.packages = [ herdr ];

        programs.claude-code = {
          skills.herdr = "${herdr.src}/skills/herdr";

          settings = {
            hooks.SessionStart = [
              {
                matcher = "^(startup|resume|clear|compact|fork)$";
                hooks = [
                  {
                    type = "command";
                    command = "${hook} session";
                  }
                ];
              }
            ];
          };
        };
      }
    );
  };
}
