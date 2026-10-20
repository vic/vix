# herdr: terminal multiplexer for coding agents (numtide/llm-agents.nix).
# Declarative equivalent of `herdr integration install claude` (v10), which
# cannot edit the home-manager owned settings.json.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.ai-herdr = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        llm-agents = {
          url = "github:numtide/llm-agents.nix/d058453d8128aaeaba2c02275bac259913a0dd3e";
          inputs = {
            bun2nix.follows = "bun2nix";
            flake-parts.follows = "flake-parts";
            nixpkgs.follows = "nixpkgs";
            systems.follows = "systems";
            treefmt-nix.follows = "treefmt-nix";
          };
        };
        bun2nix = {
          url = "github:Mic92/bun2nix/07a5bfc8ac36c5370199343fa620b69f63186e33";
          inputs = {
            flake-parts.follows = "flake-parts";
            nixpkgs.follows = "nixpkgs";
            systems.follows = "nix-systems";
            treefmt-nix.follows = "treefmt-nix";
          };
        };
        flake-parts = {
          url = "github:hercules-ci/flake-parts/024633cd702b10285db5cb19b40ad48d2399ba60";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs-lib.follows = "nixpkgs";
        nix-systems.url = "github:nix-systems/default/d36eeed142f88b5a636f2e3856a53c61654cf29b";
        systems.url = "github:nix-systems/default/d36eeed142f88b5a636f2e3856a53c61654cf29b";
      };
    claude-allow = { ... }: [ "Bash(herdr *)" ];
    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      let
        herdr = (vix.perSystem pkgs inputs.llm-agents).packages.herdr;

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
      };
  };
}
