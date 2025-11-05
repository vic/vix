{

  vic.admin =
    { user, ... }:
    {
      darwin.system.primaryUser = user.userName;
      nixos.users.users.${user.userName} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };

}
