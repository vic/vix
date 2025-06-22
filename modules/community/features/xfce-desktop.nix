{

  flake.modules.nixos.xfce-desktop = {
    # https://gist.github.com/nat-418/1101881371c9a7b419ba5f944a7118b0
    services.xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
    };

    services.displayManager = {
      defaultSession = "xfce";
      enable = true;
    };
  };

}
