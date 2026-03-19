{ ci, lib, ... }:
let
  inherit (ci) nargun;
  vic = ci.vicHm nargun;

  hmPkg = name: lib.head (lib.filter (p: name == lib.getName p) vic.home.packages);
in
{
  flake.tests.nargun = {

    test-has-ghostty = {
      expr = hmPkg "ghostty" != null;
      expected = true;
    };

    test-has-gparted = {
      expr = hmPkg "gparted" != null;
      expected = true;
    };

    test-defines-nh-root = {
      expr = vic.home.sessionVariables.NH_FILE;
      expected = ../..;
    };

  };
}
