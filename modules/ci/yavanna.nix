{ ci, ... }:
let
  inherit (ci) yavanna vicHm pkgNamed;
  vic = vicHm yavanna;
  hasPkg = name: pkgNamed name vic.home.packages != null;
in
{
  flake.tests.yavanna = {
    test-has-iterm2 = {
      expr = hasPkg "iterm2";
      expected = true;
    };
  };
}
