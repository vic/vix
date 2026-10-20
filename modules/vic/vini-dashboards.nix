# vini-dashboards: loopback web dashboards on vini, reached via the vini-tunnel forwards (sys/ssh.nix). DISABLED: no `at`.
{ inputs, ren, ... }:
let
  vix = ren.helpers;
in
{
  ren.aspects.vic-vini-dashboards.homeManager =
    {
      config,
      pkgs,
      ...
    }:
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
            "${(vix.perSystem pkgs inputs.llm-agents).packages.agentsview}/bin/agentsview serve --host 127.0.0.1 --port 8080 --no-browser --public-url http://127.0.0.1:18080"
            { };

        omni-sqlite-web =
          service "sqlite-web over omni.db (read-only)"
            "${pkgs.sqlite-web}/bin/sqlite_web --host 127.0.0.1 --port 8001 --no-browser --read-only ${omniDb}"
            { ConditionPathExists = omniDb; };
      };
    };
}
