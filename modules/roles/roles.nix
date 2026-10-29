# Roles: aspects machines derive from facts or activate in their host file; users gate on on-graphical and on-trusted.
{ yen, ... }:
let
  inherit (yen.lib) all not within;
  inherit (yen.helpers) linux;
  # a user under a scope holding the role, with no guest in between that lacks it (a guest is its own machine).
  inRole =
    role:
    all [
      yen.kinds.user
      (within role)
      (not (within (all [
        yen.kinds.guest
        (not role)
      ])))
    ];
in
{
  yen.aspects.graphical.at = [
    (all [
      linux
      (s: s.desktops != [ ] || s.form == "wsl")
    ]) # gui apps, gui dotfiles
    (all [
      yen.kinds.mac
      (s: s.workstation)
    ])
  ];
  yen.aspects.installer.at = all [
    linux
    (s: s.form == "iso")
  ]; # an iso image: no heavy home packages
  yen.aspects.trusted.at = [ ]; # holds vic's secrets: sops, ssh keys. A host file adds itself to `at`.

  yen.aspects.on-graphical.at = inRole yen.aspects.graphical;
  yen.aspects.on-trusted.at = inRole yen.aspects.trusted;
}
