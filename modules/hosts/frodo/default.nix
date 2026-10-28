# frodo: vic's laptop. A workstation (bootable), mac keys, laptop; hardware via autoinclude; apps and desktop in session.nix.
{ sven, ... }:
{
  sven.host.frodo = {
    system = sven.system.x86_64-linux;
    users = [ sven.user.vic ];
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
  sven.aspects.trusted.at = sven.host.frodo;

  sven.aspects.frodo-base = {
    at = sven.host.frodo;
    nixos = {
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "26.11";
    };
  };
}
