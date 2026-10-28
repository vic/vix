# lightjj: browser UI for jj, served from wherever the repo lives (also headless vini).
{ sven, inputs, ... }:
let
  lightjj = pkgs: (sven.helpers.perSystem pkgs inputs.lightjj).packages.default;
  port = 8765;
in
{
  sven.aspects.ai-lightjj = {
    at = sven.aspects.vic-headless;
    ports = [
      {
        inherit port;
        what = "lightjj";
      }
    ];
    flake-file.inputs.lightjj = {
      url = "github:chronologos/lightjj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ (lightjj pkgs) ];
        programs.claude-code.skills.lightjj = "${inputs.lightjj}/cmd/lightjj/SKILL.md";
      };

    # One instance; extra repos are tabs (UI, or POST /tabs {"path"}), persisted in lightjj state.json.
    homeLinux =
      { pkgs, config, ... }:
      {
        systemd.user.services.lightjj = {
          Unit.Description = "lightjj multi-repo jj UI";
          Service = {
            ExecStart = "${lightjj pkgs}/bin/lightjj -R ${config.home.homeDirectory}/hk/vix --addr 127.0.0.1:${toString port} --no-browser";
            Restart = "on-failure";
            Nice = 10;
            MemoryMax = "512M";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
