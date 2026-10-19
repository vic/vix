# dots: dotfiles linked into $HOME; live out-of-store links into ~/.flake on live-dots machines, else store copies.
{
  ren,
  vicAt,
  mod,
  ...
}:
let
  linker =
    live: config: path:
    if live then
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.flake/modules/vic/dots/${path}"
    else
      builtins.path {
        path = ./dots + "/${path}";
        name = "dots-" + builtins.replaceStrings [ "/" ] [ "-" ] path;
      };
in
{
  ren.aspects.vic-dots = {
    at = vicAt.core;
    homeManager =
      { parent, is, ... }:
      mod (
        { config, lib, ... }:
        let
          live = is ren.aspects.live-dots parent;
          dotsLink = linker live config;
        in
        {
          home.activation.link-flake = lib.mkIf live (
            config.lib.dag.entryAfter [ "writeBoundary" ] ''
              echo Checking that "$HOME/.flake" exists.
              if ! test -L "$HOME/.flake"; then
                echo "Missing $HOME/.flake link"
                exit 1
              fi
            ''
          );
          home.file.".ssh" = {
            recursive = true;
            source = ./dots/ssh;
          };
          home.file.".config/jjui".source = dotsLink "config/jjui";
          home.file.".config/nvim".source = dotsLink "config/nvim";
          home.file.".config/astrovim".source = dotsLink "config/astrovim";
          home.file.".config/lazyvim".source = dotsLink "config/lazyvim";
          home.file.".config/btop".source = dotsLink "config/btop";
          home.file.".config/bottom".source = dotsLink "config/bottom";
          home.file.".config/rtk".source = dotsLink "config/rtk";
          home.file.".config/gh/config.yml".source = dotsLink "config/gh/config.yml";
        }
      );
  };

  ren.aspects.vic-gui-dots = {
    at = vicAt.desktop;
    homeManager =
      { parent, is, ... }:
      mod (
        { config, pkgs, ... }:
        let
          dotsLink = linker (is ren.aspects.live-dots parent) config;
          uname = pkgs.stdenv.hostPlatform.uname.system;
        in
        {
          home.file.".config/niri".source = dotsLink "config/niri";
          home.file.".config/vscode-vim".source = dotsLink "config/vscode-vim";
          home.file.".config/doom".source = dotsLink "config/doom";
          home.file.".config/zed".source = dotsLink "config/zed";
          home.file.".config/wezterm".source = dotsLink "config/wezterm";
          home.file.".config/ghostty".source = dotsLink "config/ghostty";
          home.file.".config/noctalia".source = dotsLink "config/noctalia";
          home.file.".config/fontconfig".source = dotsLink "config/fontconfig";
          home.file.".config/autostart/lxqt-config-touchpad-autostart.desktop".source =
            dotsLink "config/autostart/lxqt-config-touchpad-autostart.desktop";
          home.file.".config/Code/User/settings.json".source = dotsLink "config/Code/User/settings.json";
          home.file.".config/Code/User/keybindings.json".source =
            dotsLink "config/Code/User/keybindings.json";
          home.file.".vscode/extensions/extensions.json".source =
            dotsLink "vscode/extensions/extensions-${uname}.json";
          home.file.".config/Cursor/User/settings.json".source = dotsLink "config/Code/User/settings.json";
          home.file.".config/Cursor/User/keybindings.json".source =
            dotsLink "config/Code/User/keybindings.json";
          home.file.".cursor/extensions/extensions.json".source =
            dotsLink "cursor/extensions/extensions-${uname}.json";
        }
      );
  };
}
