# Roles: aspects user features gate on with `inRole`; graphical and installer derive from machine facts.
{
  ren,
  hostWhen,
  macWhen,
  ...
}:
let
  inherit (ren.lib) and not within;
in
{
  # under a scope holding the role, with no guest in between that lacks it (a guest is its own machine).
  _module.args.inRole =
    role:
    and [
      (within role)
      (not (
        within (and [
          ren.kinds.guest
          (not role)
        ])
      ))
    ];

  ren.aspects.graphical.at = ren.lib.anyOf [
    (hostWhen (h: h.desktops != [ ] || h.form == "wsl")) # gui apps, gui dotfiles
    (macWhen (m: m.workstation))
  ];
  ren.aspects.installer.at = hostWhen (h: h.form == "iso"); # an iso image: no heavy home packages
  ren.aspects.trusted = { }; # holds vic's secrets: sops, ssh keys
  ren.aspects.live-dots = { }; # has the ~/.flake checkout: dotfiles link live into it
}
