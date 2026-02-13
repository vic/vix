{ vix, ... }:
{

  den.default.includes = [
    { nixos.passthru = { }; }
    (vix.facter ./.)
  ];

}
