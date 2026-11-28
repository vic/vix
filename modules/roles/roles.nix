# Roles: 100% pure-Nix Datalog selectors (zero lambda predicates, zero string enums!).
{
  yen,
  at,
  ...
}:
{
  yen.aspects.graphical.at = at.anyOf [
    (yen.kinds.host.where { desktops = at.nonEmpty; })
    (yen.kinds.host.where { form = yen.form.wsl; })
    (yen.kinds.mac.where { workstation = true; })
    (yen.kinds.home.where { graphical = true; })
  ];

  yen.aspects.installer.at = yen.kinds.host.where { form = yen.form.iso; };

  yen.aspects.trusted.at = yen.kinds.place.where { trusted = true; };

  yen.aspects.on-graphical.at = at.all [
    yen.kinds.user
    (at.nearest yen.kinds.place yen.aspects.graphical)
  ];

  yen.aspects.on-trusted.at = at.all [
    yen.kinds.user
    (at.nearest yen.kinds.place yen.aspects.trusted)
  ];
}
