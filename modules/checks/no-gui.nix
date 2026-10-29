# no-gui: flake checks no-gui-<user>@<place> fail when a headless home (standalone or guest) installs a gui .desktop entry.
{ yen, ... }:
let
  inherit (yen.lib) all not within;
  headless =
    kind:
    all [
      yen.kinds.user
      (within kind)
      (not yen.aspects.on-graphical)
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
in
{
  yen.aspects.no-gui-home = {
    at = headless yen.kinds.home;
    checks =
      {
        user,
        home,
        out,
        ...
      }:
      check home.system "${user.name}@${home.name}"
        out.homeConfigurations."${user.name}@${home.name}".config.home.path;
  };
  yen.aspects.no-gui-guest = {
    at = headless yen.kinds.guest;
    checks =
      {
        user,
        guest,
        out,
        ...
      }:
      check guest.system "${user.name}@${guest.name}"
        out.nixosConfigurations.${guest.on.name}.config.microvm.vms.${guest.name}.config.config.home-manager.users.${user.name}.home.path;
  };
}
