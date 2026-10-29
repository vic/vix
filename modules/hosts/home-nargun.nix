# nargun: vic's standalone home on the nargun workstation (full, graphical, trusted).
{ yen, ... }:
{
  yen.home.nargun = {
    checkout = "/home/vic/hk/vix";
    user = yen.user.vic;
    on = yen.host.nargun;
    system = yen.system.x86_64-linux;
  };
  yen.aspects.graphical.at = yen.home.nargun;
  yen.aspects.trusted.at = yen.home.nargun;
}
