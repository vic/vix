{
  vic.everywhere.nixos =
    { pkgs, ... }:
    {
      users.users.vic.packages = with pkgs; [
        nh
        jq
        direnv
        ghostty
      ];
    };
}
