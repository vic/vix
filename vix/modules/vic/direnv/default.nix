{ USER, ... }: {
  _module.args = { direnv_dir = ".nix-out/direnv"; };
  imports = [ ./lorri.nix ./shell.nix ];

  home-manager.users.${USER} = {
    programs.direnv.enable = true;
    # programs.direnv.enableFishIntegration = true;
  };
}
