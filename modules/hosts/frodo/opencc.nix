# frodo opencc: OpenAI API on localhost:9898 that talks to vic's Claude Code sessions (the API key is the session name).
{
  yen,
  at,
  inputs,
  ...
}:
let
  opencc = pkgs: (yen.helpers.perSystem pkgs inputs.opencc).packages.default;
  port = 9898;
in
{
  yen.aspects.frodo-opencc = {
    at = at.all [
      yen.kinds.user
      (at.under yen.host.frodo)
    ];
    ports = [
      {
        inherit port;
        what = "opencc";
      }
    ];
    flake-file.inputs.opencc = {
      url = "github:vic/opencc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [ (opencc pkgs) ];
        systemd.user.services.opencc = {
          Unit.Description = "opencc: OpenAI API for Claude Code sessions";
          Service = {
            ExecStart = "${opencc pkgs}/bin/opencc --listen 127.0.0.1:${toString port}";
            Restart = "on-failure";
            Nice = 10;
            MemoryMax = "256M";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
