{
  vix.xserver.nixos = {
    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
