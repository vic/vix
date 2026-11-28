# frodo agcc: Anthropic & OpenAI API bridge on localhost:9899 over one warm `agy acp` (Antigravity).
# claudy: Claude Code on agy, with its own in-process agcc (no service needed).
{
  yen,
  at,
  inputs,
  ...
}:
let
  agcc = pkgs: (yen.helpers.perSystem pkgs inputs.agcc).packages.default;
  agy = pkgs: "${(yen.helpers.perSystem pkgs inputs.llm-agents).packages.antigravity-cli}/bin/agy";
  port = 9899;
in
{
  yen.aspects.frodo-agcc = {
    at = at.all [
      yen.kinds.user
      (at.under yen.host.frodo)
    ];
    ports = [
      {
        inherit port;
        what = "agcc";
      }
    ];
    flake-file.inputs.agcc = {
      url = "github:vic/agcc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          (agcc pkgs)
          (pkgs.writeShellScriptBin "claudy" ''
            export AGCC_AGY=${agy pkgs}
            exec ${agcc pkgs}/bin/agcc claude "$@"
          '')
        ];
        systemd.user.services.agcc = {
          Unit.Description = "agcc: Anthropic & OpenAI API bridge for Google AI / Antigravity";
          Service = {
            ExecStart = "${agcc pkgs}/bin/agcc --listen 127.0.0.1:${toString port}";
            # The service PATH has no agy.
            Environment = [ "AGCC_AGY=${agy pkgs}" ];
            Restart = "on-failure";
            Nice = 10;
            # agy acp and the MCP servers it starts use about 740 MB.
            MemoryMax = "2G";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
  };
}
