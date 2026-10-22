# lightjj: browser UI for jj, served from wherever the repo lives (also headless vini).
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{

  ren.aspects.ai-lightjj = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        lightjj = {
          url = "github:chronologos/lightjj";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      { pkgs, config, ... }:
      let
        lightjj = (vix.perSystem pkgs inputs.lightjj).packages.default;
      in
      {
        home.packages = [ lightjj ];
        programs.claude-code.skills.lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";

        # One instance; extra repos are tabs (UI, or POST /tabs {"path"}), persisted in lightjj state.json.
        # mkIf, not optionalAttrs: attr names must not depend on pkgs (infinite recursion).
        systemd.user.services.lightjj = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          Unit.Description = "lightjj multi-repo jj UI";
          Service = {
            ExecStart = "${lightjj}/bin/lightjj -R ${config.home.homeDirectory}/hk/vix --addr 127.0.0.1:8765 --no-browser";
            Restart = "on-failure";
            Nice = 10;
            MemoryMax = "512M";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
