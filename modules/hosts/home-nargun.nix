# nargun: vic's standalone home on the nargun workstation (full, graphical, trusted).
{ yen, ... }:
{
  yen.home.nargun = {
    checkout = "/home/vic/hk/vix";
    user = yen.user.vic;
    graphical = true;
    trusted = true;
    on = yen.host.nargun;
    system = yen.system.x86_64-linux;
  };
}
