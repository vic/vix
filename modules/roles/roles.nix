# Roles: aspects machines derive from facts or activate in their host file; users gate on on-graphical and on-trusted.
{ sven, ... }:
let
  inherit (sven.lib) all not within;
  inherit (sven.helpers) linux;
  # a user under a scope holding the role, with no guest in between that lacks it (a guest is its own machine).
  inRole =
    role:
    all [
      sven.kinds.user
      (within role)
      (not (within (all [
        sven.kinds.guest
        (not role)
      ])))
    ];
in
{
  sven.aspects.graphical.at = [
    (all [
      linux
      (s: s.desktops != [ ] || s.form == "wsl")
    ]) # gui apps, gui dotfiles
    (all [
      sven.kinds.mac
      (s: s.workstation)
    ])
  ];
  sven.aspects.installer.at = all [
    linux
    (s: s.form == "iso")
  ]; # an iso image: no heavy home packages
  sven.aspects.trusted.at = [ ]; # holds vic's secrets: sops, ssh keys. A host file adds itself to `at`.

  sven.aspects.on-graphical.at = inRole sven.aspects.graphical;
  sven.aspects.on-trusted.at = inRole sven.aspects.trusted;
}
