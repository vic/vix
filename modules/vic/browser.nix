{
  vic.browser = {

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.librewolf
          pkgs.qutebrowser
        ];
      };

  };
}
