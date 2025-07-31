{ ... }:
let

  flake.modules.homeManager.vic.imports = [
    everywhere
    nonBombadil
    darwin
  ];

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
    lib.mkIf (osConfig.networking.hostName != "bombadil") {
      home.packages = [
        pkgs.code-cursor
        pkgs.zed-editor
      ];
    };

  everywhere =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [
        pkgs.librewolf
        pkgs.vscode
        pkgs.wezterm
      ]
      ++ (lib.optionals (pkgs.system == "aarm64-darwin" || pkgs.stdenvNoCC.isLinux) [
        pkgs.ghostty
      ])
      ++ (lib.optionals pkgs.stdenvNoCC.isLinux [
        pkgs.gnome-disk-utility
      ]);
    };

in
{
  inherit flake;
}
