# see https://github.com/rvaiya/keyd/blob/master/examples/macos.conf
{ desktop, config, ... }:
let

  # Layer for the left cmd key
  mac_leftcmd = {

    # clipboard
    c = desktop.copy;
    v = desktop.paste;
    x = desktop.cut;

    # tabs
    # Switch directly to an open tab (e.g. Firefox, VS code)
    "1" = "${desktop.switch-tab-n-prefix}-1";
    "2" = "${desktop.switch-tab-n-prefix}-2";
    "3" = "${desktop.switch-tab-n-prefix}-3";
    "4" = "${desktop.switch-tab-n-prefix}-4";
    "5" = "${desktop.switch-tab-n-prefix}-5";
    "6" = "${desktop.switch-tab-n-prefix}-6";
    "7" = "${desktop.switch-tab-n-prefix}-7";
    "8" = "${desktop.switch-tab-n-prefix}-8";
    "9" = "${desktop.switch-tab-n-prefix}-9";

    # cursor
    left = desktop.beginning-of-line;
    right = desktop.end-of-line;

    # windows
    q = desktop.close-app;
    t = desktop.new-tab;
    w = desktop.close-tab;
    tab = "swapm(mac_leftcmd, ${desktop.next-app})";

  };

  # Layer for the left opt key
  mac_leftopt = { };

  mac_rightctrl = { };

in
{

  # Left Alt (left from spacebar) becomes MacOS Command layer.
  main.leftalt = "layer(mac_leftcmd)";
  "mac_leftcmd:A" = mac_leftcmd; # inherit from original Alt layer

  # # Left Meta (two left from spacebar) becomes MacOS Option layer.
  main.leftmeta = "layer(mac_leftopt)";
  "mac_leftopt:M" = mac_leftopt; # inherit from original Meta layer

  # Right Alt (right from spacebar) becomes additional Ctrl layer.
  main.rightalt = "overload(mac_rightctrl, esc)";
  "mac_rightctrl:C" = mac_rightctrl;

}
