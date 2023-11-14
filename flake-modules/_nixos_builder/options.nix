top@{lib, ...}: {builder}: 
let 
  inherit (lib) mkOption;
in
{name, config, ...}: {
      options = {
        builder = mkOption {
          description = "Function used to create the nixos configuration.";
          inherit (builder.fn) default example;
        };

        hmModule = mkOption {
          description = ''
          home-manager's nixos module to include.

          NOTE: If you are using nixpkgs stable release, be sure to also use hm stable release.
          '';
          inherit (builder.hm) default example;
        };

        module = mkOption {
          description = "Main configuration module to load";
          inherit (builder.mod name) default example;
        };

        extraModules = mkOption {
          description = "Extra modules to load";
          inherit (builder.extraMods name) default example;
        };
      };
    }