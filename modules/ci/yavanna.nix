{ ci, ... }:
let
  inherit (ci) yavanna hasPkg;
  vic = ci.vicHm yavanna;
in
{
  flake.tests.yavanna = {
    test-has-iterm2 = {
      expr = hasPkg "iterm2" vic.home.packages;
      expected = true;
    };
  };
}
