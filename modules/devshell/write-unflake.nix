{
  dev.apps.npins = pkgs: pkgs.npins;

  dev.apps.write-unflake =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-unflake";
      text = ''
        nix-shell default.nix -A unflake.env --run "write-unflake $*"
      '';
    };

  dev.apps.write-npins =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-npins";
      text = ''
        nix-shell npins.nix -A flake-file.sh --run write-npins
      '';
    };

  dev.apps.write-deps =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-deps";
      text = ''
        nix-shell npins.nix -A flake-file.sh --run write-deps
      '';
    };

  dev.apps.write-inputs =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-inputs";
      text = ''
        nix-shell default.nix -A unflake.env --run "write-inputs $*"
      '';
    };
}
