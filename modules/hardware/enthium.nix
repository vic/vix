# enthium: Enthium keyboard layout, on hosts that list yen.layout.enthium.
{
  yen,
  at,
  inputs,
  ...
}:
{
  yen.aspects.enthium = {
    at = yen.kinds.host.where { layouts = at.contains yen.layout.enthium; };
    flake-file.inputs.enthium = {
      url = "github:sunaku/enthium";
      flake = false;
    };
    nixos.services.xserver.xkb.extraLayouts.enthium = {
      description = "Enthium";
      languages = [ "eng" ];
      symbolsFile = "${inputs.enthium}/linux/usr-share-X11-xkb-symbols-us";
    };
  };
}
