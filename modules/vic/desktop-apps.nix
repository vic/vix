{ ... }:
let
  darwin =
    { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenvNoCC.isDarwin {
      home.packages = [ pkgs.iterm2 ];
    };

  nonBombadil =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    lib.mkIf (pkgs.stdenvNoCC.isLinux && osConfig.networking.hostName != "bombadil") {
      home.packages = [
        pkgs.code-cursor
        pkgs.zed-editor
      ];
    };

  everywhere =
    { pkgs, lib, ... }:
    {
      home.packages = [
        pkgs.librewolf
      ]
      ++ (lib.optionals
        (pkgs.stdenvNoCC.hostPlatform.system == "aarm64-darwin" || pkgs.stdenvNoCC.isLinux)
        [
          pkgs.ghostty
        ]
      )
      ++ (lib.optionals pkgs.stdenvNoCC.isLinux [
        pkgs.gnome-disk-utility
        pkgs.vscode
        pkgs.wezterm
      ]);
    };
in
{
  vic.desktop-apps.homeManager.imports = [
    everywhere
    nonBombadil
    darwin
  ];
}
