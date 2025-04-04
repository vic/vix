# see https://raw.githubusercontent.com/rvaiya/keyd/refs/heads/master/docs/keyd.scdoc
# see https://github.com/rvaiya/keyd/blob/master/examples/macos.conf
{ desktop, ... }:
let

  # MacOS Command (⌘)
  mac_cmd = {

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

  # MacOS Option (⌥)
  mac_opt = { };

  # Macos Meh (⌃⌥⇧)
  mac_meh = { };

  # Hyper (⌃⌥⇧⌘)
  mac_hyper = {
    h = "left";
    j = "down";
    k = "up";
    l = "right";
  };

in
{

  # Left Alt (left from spacebar) becomes MacOS Command
  main.leftalt = "overload(layer(mac_leftcmd), esc)";
  "mac_leftcmd:A" = mac_cmd; # Keep original Alt

  # Right Alt (right from spacebar) becomes MacOS Command
  main.rightalt = "overload(layer(mac_rightcmd), esc)";
  "mac_rightcmd:A" = mac_cmd; # Keep original Alt

  # Left Meta (two left from spacebar) becomes MacOS Option
  main.leftmeta = "overload(layer(mac_leftopt), esc)";
  "mac_leftopt:M" = mac_opt; # inherit from original Meta layer

  # Right Ctrl (two right from spacebar) becomes Macos Meh
  main.rightcontrol = "overload(mac_meh, esc)";
  "mac_meh:C-A-S" = mac_meh; # ⌃⌥⇧ -> Ctrl+Alt+Shift

  main.leftcontrol = "overload(mac_hyper, esc)";
  "mac_hyper:C-A-S-M" = mac_hyper; # ⌃⌥⇧⌘ -> Ctrl+Alt+Shift+Meta

}
