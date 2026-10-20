# editors: gui editors, vscode vim hook, vscode-server and the unfree editors.
{
  ren,
  inputs,
  ...
}:
let
  vix = ren.helpers;
  at = ren.lib.and [
    ren.aspects.vic-full
    ren.aspects.vic-gui
  ];
in
{
  ren.aspects.vic-vscode-server.homeManager =
    { pkgs, ... }:
    {
      imports = [ "${inputs.vscode-server}/modules/vscode-server/home.nix" ];

      services.vscode-server = {
        enable = true;
        nodejsPackage = pkgs.nodejs_latest;
        extraRuntimeDependencies = with pkgs; [
          curl
          wget
        ];
      };
    };

  ren.aspects.vic-editors = {
    inherit at;
    flake-inputs =
      { ... }:
      {
        vscode-server = {
          url = "github:nix-community/nixos-vscode-server/2f984dfbe7e5271b5c413d3e734374cc1306c921";
          inputs.flake-parts.follows = "flake-parts";
        };
        flake-parts = {
          url = "github:hercules-ci/flake-parts/024633cd702b10285db5cb19b40ad48d2399ba60";
          inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };
        nixpkgs-lib.follows = "nixpkgs";
      };
    includes = [ ren.aspects.vic-vscode-server ];
    dots =
      { parent, ... }:
      let
        ext = if (vix.place parent).system.darwin then "Darwin" else "Linux";
      in
      {
        ".config/zed" = "config/zed";
        ".config/vscode-vim" = "config/vscode-vim";
        ".config/Code/User/settings.json" = "config/Code/User/settings.json";
        ".config/Code/User/keybindings.json" = "config/Code/User/keybindings.json";
        ".config/Cursor/User/settings.json" = "config/Code/User/settings.json";
        ".config/Cursor/User/keybindings.json" = "config/Code/User/keybindings.json";
        ".vscode/extensions/extensions.json" = "vscode/extensions/extensions-${ext}.json";
        ".cursor/extensions/extensions.json" = "cursor/extensions/extensions-${ext}.json";
      };
    unfree = vix.allowUnfree [
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
