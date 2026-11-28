# gebed: browser UI for beads (br + bd), served from the home like lightjj (also headless vini).
{
  yen,
  inputs,
  lib,
  ...
}:
let
  gebed = pkgs: (yen.helpers.perSystem pkgs inputs.gebed).packages.default;
  port = 7878;
in
{
  yen.aspects.ai-gebed = {
    at = yen.aspects.vic-headless;
    ports = [
      {
        inherit port;
        what = "gebed";
      }
    ];
    flake-file.inputs.gebed = {
      url = "github:vic/gebed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ (gebed pkgs) ];
        # gebed-pm skill and gebed MCP both ship from the gebed flake input.
        programs.claude-code = {
          skills.gebed-pm = "${inputs.gebed}/internal/skill/gebed-pm";
          mcpServers.gebed = {
            type = "stdio";
            command = lib.getExe (gebed pkgs);
            args = [ "mcp" ];
          };
        };
      };

    # gebed runs `br` and reads what it prints, so the unit needs br on PATH. Repos are registered
    # once (`gebed <repo>...`) and remembered in its state.
    homeLinux =
      { pkgs, ... }:
      let
        llm = (yen.helpers.perSystem pkgs inputs.llm-agents).packages;
      in
      {
        systemd.user.services.gebed = {
          Unit.Description = "gebed beads UI";
          Service = {
            ExecStart = "${gebed pkgs}/bin/gebed --addr 127.0.0.1:${toString port}";
            Environment = [ "PATH=${lib.makeBinPath [ llm.beads-rust ]}" ];
            Restart = "on-failure";
            Nice = 10;
            MemoryMax = "512M";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
