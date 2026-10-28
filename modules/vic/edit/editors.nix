# editors: gui editors, vscode vim hook, vscode-server and the unfree editors.
{
  sven,
  inputs,
  lib,
  ...
}:
{
  sven.aspects.vic-vscode-server = {
    at = sven.aspects.vic-editors; # an include in Ren: active wherever vic-editors is
    homeManager =
      { pkgs, ... }:
      {
        imports = [ "${inputs.vscode-server}/modules/vscode-server/home.nix" ];

        services.vscode-server = {
          enable = true;
          nodejsPackage = pkgs.nodejs_latest;
          extraRuntimeDependencies = [
            pkgs.curl
            pkgs.wget
          ];
        };
      };
  };

  sven.aspects.vic-editors = {
    at = sven.lib.all [
      sven.aspects.vic-full
      sven.aspects.vic-gui
    ];
    flake-file.inputs = {
      vscode-server = {
        url = "github:nix-community/nixos-vscode-server";
        inputs.flake-parts.follows = "flake-parts";
      };
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      };
      nixpkgs-lib.follows = "nixpkgs";
    };
    dots =
      { scope, ... }:
      {
        ".config/zed" = "config/zed";
        ".config/vscode-vim" = "config/vscode-vim";
        ".config/Code/User/settings.json" = "config/Code/User/settings.json";
        ".config/Code/User/keybindings.json" = "config/Code/User/keybindings.json";
        ".config/Cursor/User/settings.json" = "config/Code/User/settings.json";
        ".config/Cursor/User/keybindings.json" = "config/Code/User/keybindings.json";
      }
      # extension lists exist for Linux only: no darwin link to a missing file
      // lib.optionalAttrs (!(sven.helpers.place scope).system.darwin) {
        ".vscode/extensions/extensions.json" = "vscode/extensions/extensions-Linux.json";
        ".cursor/extensions/extensions.json" = "cursor/extensions/extensions-Linux.json";
      };
    unfree = sven.helpers.allowUnfree [
      "cursor"
      "vscode"
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.helix
          pkgs.lapce
          pkgs.flow-control
          pkgs.code-cursor
          pkgs.zed-editor
          pkgs.vscode
        ];
        home.file.".config/fish/conf.d/vscode-vim.fish".text = ''
          if test "$VSCODE_INJECTION" = "1"
            set -x VISUAL code
          end
        '';
      };
  };
}
