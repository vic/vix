{
  vic.everywhere.user =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        nh
        jq
        direnv
        ghostty
      ];
    };
}
