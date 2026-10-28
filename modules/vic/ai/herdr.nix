# herdr: terminal multiplexer for coding agents (numtide/llm-agents.nix).
# Declarative equivalent of `herdr integration install claude` (v10), which
# cannot edit the home-manager owned settings.json.
{ sven, inputs, lib, ... }:
{
  sven.aspects.ai-herdr = {
    at = sven.aspects.vic-headless;
    flake-file.inputs = {
      llm-agents = {
        url = "github:numtide/llm-agents.nix";
        inputs = {
          bun2nix.follows = "bun2nix";
          flake-parts.follows = "flake-parts";
          nixpkgs.follows = "nixpkgs";
          systems.follows = "systems";
          treefmt-nix.follows = "treefmt-nix";
        };
      };
      bun2nix = {
        url = "github:Mic92/bun2nix";
        inputs = {
          flake-parts.follows = "flake-parts";
          nixpkgs.follows = "nixpkgs";
          systems.follows = "nix-systems";
          treefmt-nix.follows = "treefmt-nix";
        };
      };
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      };
      nixpkgs-lib.follows = "nixpkgs";
      nix-systems.url = "github:nix-systems/default";
      systems.url = "github:nix-systems/default";
    };
    claude-allow = [ "Bash(herdr *)" ];
    homeManager =
      { pkgs, ... }:
      let
        herdr = (sven.helpers.perSystem pkgs inputs.llm-agents).packages.herdr;

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

          settings.hooks.SessionStart = [
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
  };
}
