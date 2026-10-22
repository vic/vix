# no-gui: flake checks no-gui-<user>@<place> fail when a headless home (standalone or guest) installs a gui .desktop entry.
{
  ren,
  inputs,
  ...
}:
let
  inherit (ren.lib) and not within;
  headless =
    kind:
    and [
      ren.kinds.user
      (within kind)
      (not ren.aspects.on-graphical)
    ];
  # every share/applications/*.desktop in the home path must be a terminal app.
  check = system: name: homePath: {
    ${system.name}."no-gui-${name}" = system.legacyPackages.runCommand "no-gui-${name}" { } ''
      bad=0
      for f in ${homePath}/share/applications/*.desktop; do
        [ -e "$f" ] || continue
        grep -q '^Terminal=true' "$f" || { echo "gui app: $(basename "$f")"; bad=1; }
      done
      [ "$bad" = 0 ] && touch $out
    '';
  };
  self = inputs.self; # shortcut: reads home paths back from flake outputs; no class exposes hm config to a channel
in
{
  ren.aspects.no-gui-home = {
    at = headless ren.kinds.home;
    checks =
      { user, home, ... }:
      check home.system "${user.name}@${home.name}"
        self.homeConfigurations."${user.name}@${home.name}".config.home.path;
  };
  ren.aspects.no-gui-guest = {
    at = headless ren.kinds.guest;
    checks =
      { user, guest, ... }:
      check guest.system "${user.name}@${guest.name}"
        self.nixosConfigurations.${guest.on.name}.config.microvm.vms.${guest.name}.config.config.home-manager.users.${user.name}.home.path;
  };
}
