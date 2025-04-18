{
  pkgs,
  osConfig,
  lib,
  ...
}:
{

  home.packages =
    ([
      pkgs.librewolf
      pkgs.vscode
      pkgs.wezterm
      pkgs.ghostty
    ])
    ++ (lib.optionals (osConfig.networking.hostName != "bombadil") [
      pkgs.code-cursor
      pkgs.zed-editor
    ]);

}
