# no-gui: flake checks fail when a headless home (standalone or guest) installs a gui .desktop entry.
{ yen, at, ... }:
let
  headless =
    kind:
    at.all [
      yen.kinds.user
      (at.under kind)
      (at.not yen.aspects.on-graphical)
    ];
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
