# nargun: vic's standalone home on the nargun workstation (full, graphical, trusted).
{ ren, ... }:
{
  ren.home.nargun = {
    checkout = "/home/vic/hk/vix";
    user = ren.user.vic;
    system = ren.system.x86_64-linux;
  };

  ren.aspects.nargun-home = {
    at = ren.home.nargun;
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
    ];
  };
}
