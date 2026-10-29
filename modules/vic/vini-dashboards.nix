# vini-dashboards: loopback web dashboards on vini, reached via the vini-tunnel forwards (sys/ssh.nix). DISABLED: `at` is empty.
{ yen, inputs, ... }:
let
  agentsview = 8080;
  omni = 8001;
in
{
  yen.aspects.vic-vini-dashboards = {
    at = [ ];
    ports = [
      {
        port = agentsview;
        what = "agentsview";
      }
      {
        port = omni;
        what = "omni-sqlite-web";
      }
    ];
    homeManager =
      { config, pkgs, ... }:
      let
        service = description: ExecStart: extraUnit: {
          Unit = {
            Description = description;
          }
          // extraUnit;
          Service = {
            inherit ExecStart;
            Restart = "on-failure";
            RestartSec = 10;
          };
          Install.WantedBy = [ "default.target" ];
        };
        omniDb = "${config.home.homeDirectory}/.claude/omni.db";
      in
      {
        systemd.user.services = {
          # ~/.claude session browser; public-url is frodo's forwarded port.
          agentsview =
            service "agentsview session browser"
              "${(yen.helpers.perSystem pkgs inputs.llm-agents).packages.agentsview}/bin/agentsview serve --host 127.0.0.1 --port ${toString agentsview} --no-browser --public-url http://127.0.0.1:${toString (10000 + agentsview)}"
              { };

          omni-sqlite-web =
            service "sqlite-web over omni.db (read-only)"
              "${pkgs.sqlite-web}/bin/sqlite_web --host 127.0.0.1 --port ${toString omni} --no-browser --read-only ${omniDb}"
              { ConditionPathExists = omniDb; };
        };
      };
  };
}
