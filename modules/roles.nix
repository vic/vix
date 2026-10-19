# Roles: aspects user features gate on with `within`; graphical and installer derive from machine facts.
{
  ren,
  hostWhen,
  macWhen,
  ...
}:
{
  ren.aspects.graphical.at = ren.lib.anyOf [
    (hostWhen (h: h.desktops != [ ] || h.form == "wsl")) # gui apps, gui dotfiles
    (macWhen (m: m.workstation))
  ];
  ren.aspects.installer.at = hostWhen (h: h.form == "iso"); # an iso image: no heavy home packages
  ren.aspects.trusted = { }; # holds vic's secrets: sops, ssh keys
  ren.aspects.live-dots = { }; # has the ~/.flake checkout: dotfiles link live into it
}
