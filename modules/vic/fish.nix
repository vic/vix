{
  vix.vic.provides.fish =
    { user, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          programs.fish.enable = true;
          users.users.${user.userName}.shell = pkgs.fish;
        };

      homeManager = {
        programs.fzf.enable = true;
        # programs.fzf.enableFishIntegration = true;
        programs.fish.enable = true;
      };
    };
}
