{ vix, ... }:
{
  den.default.nixos.system.stateVersion = "25.11";

  den.ctx.host.includes = [ (vix.facter ./.) ];
}
