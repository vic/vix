# enthium: the Enthium keyboard layout.
{ inputs, ... }:
{
  ren.aspects.enthium.nixos.services.xserver.xkb.extraLayouts.enthium = {
    description = "Enthium";
    languages = [ "eng" ];
    symbolsFile = "${inputs.enthium}/linux/usr-share-X11-xkb-symbols-us";
  };
}
