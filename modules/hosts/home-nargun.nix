# nargun: vic's standalone home on the nargun workstation (full, graphical, trusted).
{ sven, ... }:
{
  sven.home.nargun = {
    checkout = "/home/vic/hk/vix";
    user = sven.user.vic;
    on = sven.host.nargun;
    system = sven.system.x86_64-linux;
  };
  sven.aspects.graphical.at = sven.home.nargun;
  sven.aspects.trusted.at = sven.home.nargun;
}
