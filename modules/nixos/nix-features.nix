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
          ];
        }
        .${config.networking.hostName} or [ ];

      allowed = builtins.elem name (global ++ perHost);
      msg = if allowed then "Allowed unfree: ${name}" else "Not allowed unfree ${name}";
    in
    builtins.trace msg allowed;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = [
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
    gc = pkgs.lib.optionalAttrs config.nix.enable {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
