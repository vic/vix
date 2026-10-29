# enthium: the Enthium keyboard layout, on hosts that list it.
{ yen, inputs, ... }:
{
  yen.aspects.enthium = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: builtins.elem "enthium" s.layouts)
    ];
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
