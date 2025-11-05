{
  vic.browser = _: {

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
