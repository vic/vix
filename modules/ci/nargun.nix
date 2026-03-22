{ ci, ... }:
let
  inherit (ci) nargun vicHm pkgNamed;
  vic = vicHm nargun;
  hasPkg = name: pkgNamed name vic.home.packages != null;
in
{
  flake.tests.nargun = {

    test-has-ghostty = {
      expr = hasPkg "ghostty";
      expected = true;
    };

    test-has-gparted = {
      expr = hasPkg "gparted";
      expected = true;
    };

    test-defines-nh-root = {
      expr = vic.home.sessionVariables.NH_FILE;
      expected = ../..;
    };

  };
}
