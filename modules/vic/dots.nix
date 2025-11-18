{
  # Use hjem instead of mkOutOfStoreSymlink !
  vic.dots = {
    homeManager =
      { config, pkgs, ... }:
      let
        dotsLink =
          path:
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.flake/modules/vic/dots/${path}";
      in
      {
        home.activation.link-flake = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          echo Checking that "$HOME/.flake" exists.
          if ! test -L "$HOME/.flake"; then
            echo "Missing $HOME/.flake link"
            exit 1
          fi
        '';

        home.file.".ssh" = {
          recursive = true;
          source = ./dots/ssh;
        };

        home.file.".config/niri".source = dotsLink "config/niri";
        home.file.".config/nvim".source = dotsLink "config/nvim";
        home.file.".config/astrovim".source = dotsLink "config/astrovim";
        home.file.".config/lazyvim".source = dotsLink "config/lazyvim";
        home.file.".config/vscode-vim".source = dotsLink "config/vscode-vim";
        home.file.".config/doom".source = dotsLink "config/doom";
        home.file.".config/zed".source = dotsLink "config/zed";
        home.file.".config/wezterm".source = dotsLink "config/wezterm";
        home.file.".config/ghostty".source = dotsLink "config/ghostty";

        home.file.".config/Code/User/settings.json".source = dotsLink "config/Code/User/settings.json";
        home.file.".config/Code/User/keybindings.json".source =
          dotsLink "config/Code/User/keybindings.json";
        home.file.".vscode/extensions/extensions.json".source =
          dotsLink "vscode/extensions/extensions-${pkgs.stdenv.hostPlatform.uname.system}.json";

        home.file.".config/Cursor/User/settings.json".source = dotsLink "config/Code/User/settings.json";
        home.file.".config/Cursor/User/keybindings.json".source =
          dotsLink "config/Code/User/keybindings.json";
        home.file.".cursor/extensions/extensions.json".source =
          dotsLink "cursor/extensions/extensions-${pkgs.stdenv.hostPlatform.uname.system}.json";

      };
  };
}
