# Roles: aspects machines include or derive from facts; users gate on on-graphical and on-trusted.
{ ren, ... }:
let
  inherit (ren.lib)
    and
    anyOf
    not
    when
    within
    ;
  # a user under a scope holding the role, with no guest in between that lacks it (a guest is its own machine).
  inRole =
    role:
    and [
      ren.kinds.user
      (within role)
      (not (
        within (and [
          ren.kinds.guest
          (not role)
        ])
      ))
    ];
in
{
  ren.aspects.graphical.at = anyOf [
    (and [
      ren.kinds.host
      (when (s: s.host.desktops != [ ] || s.host.form == "wsl"))
    ]) # gui apps, gui dotfiles
    (and [
      ren.kinds.mac
      (when (s: s.mac.workstation))
    ])
  ];
  ren.aspects.installer.at = and [
    ren.kinds.host
    (when (s: s.host.form == "iso"))
  ]; # an iso image: no heavy home packages
  ren.aspects.trusted = { }; # holds vic's secrets: sops, ssh keys

  ren.aspects.on-graphical.at = inRole ren.aspects.graphical;
  ren.aspects.on-trusted.at = inRole ren.aspects.trusted;
}
