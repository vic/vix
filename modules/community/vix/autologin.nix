{
  vix.autologin = { user, ... }: {
    nixos =
      { config, lib, ... }:
      lib.mkIf config.services.displayManager.enable {
        services.displayManager.autoLogin.enable = true;
        services.displayManager.autoLogin.user = user.userName;
      };
  };
}
