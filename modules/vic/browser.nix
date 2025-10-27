{
  vix.vic.provides.browser = _: {

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
