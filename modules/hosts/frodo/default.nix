# frodo: vic's laptop. A workstation (bootable), mac keys, laptop; hardware via autoinclude; apps and desktop in session.nix.
{ yen, ... }:
{
  yen.host.frodo = {
    system = yen.system.x86_64-linux;
    users = [ yen.user.vic ];
    form = "laptop";
    workstation = true; # bootable gives boot, network, locale, bluetooth and pipewire
    keyboard = "macos";
    desktops = [
      "niri"
      "xfce"
    ];
    # vic/pm/notes/impermanence-design.md MIGRATION: enable at step 5, wipeRoot at step 8.
    impermanence = {
      enable = false;
      wipeRoot = false;
    };
  };
  yen.aspects.trusted.at = yen.host.frodo;

  yen.aspects.frodo-base = {
    at = yen.host.frodo;
    nixos = {
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "26.11";
    };
  };
}
