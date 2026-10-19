# editors: gui editors, vscode vim hook, vscode-server and the unfree editors.
{
  ren,
  vicAt,
  inputs,
  allowUnfree,
  place,
  ...
}:
let
  at = ren.lib.and [
    vicAt.full
    vicAt.gui
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
    includes = [ ren.aspects.vic-vscode-server ];
    dots =
      { parent, ... }:
      let
        ext = if (place parent).system.darwin then "Darwin" else "Linux";
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
    unfree = allowUnfree [
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
