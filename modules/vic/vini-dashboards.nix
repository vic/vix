# vini-dashboards: loopback web dashboards on vini, reached via the vini-tunnel forwards (sys/ssh.nix). DISABLED: `at` is empty.
{ yen, inputs, ... }:
let
  agentsview = 8080;
in
{
  yen.aspects.vic-vini-dashboards = {
    at = [ ];
    ports = [
      {
        port = agentsview;
        what = "agentsview";
      }
    ];
    homeManager =
      { pkgs, ... }:
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
      in
      {
        systemd.user.services = {
          # ~/.claude session browser; public-url is frodo's forwarded port.
          agentsview =
            service "agentsview session browser"
              "${(yen.helpers.perSystem pkgs inputs.llm-agents).packages.agentsview}/bin/agentsview serve --host 127.0.0.1 --port ${toString agentsview} --no-browser --public-url http://127.0.0.1:${toString (10000 + agentsview)}"
              { };
        };
      };
  };
}
