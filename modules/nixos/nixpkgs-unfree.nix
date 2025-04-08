{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    let
      name = pkgs.lib.getName pkg;

      global = [
        "copilot-language-server"
        "cursor"
        "vscode"
        "obsidian"
        "anydesk"
      ];

      perHost =
        {
          "mordor" = [
            "nvidia-x11"
            "nvidia-settings"
          ];
          "nienna" = [
            "broadcom-sta"
          ];
          "smaug" = [
            "broadcom-sta"
            "nvidia-x11"
            "nvidia-settings"
          ];
        }
        .${config.networking.hostName} or [ ];

      allowed = builtins.elem name (global ++ perHost);
      msg = if allowed then "Allowed unfree: ${name}" else "Not allowed unfree ${name}";
    in
    builtins.trace msg allowed;
}
