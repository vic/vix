{ inputs, ... }:
{

  flake-file.inputs.enthium = {
    url = "github:sunaku/enthium/v10";
    flake = false;
  };

  vix.enthium.nixos = {

    services.xserver.xkb.extraLayouts.enthium = {
      description = "Enthium";
      languages = [ "eng" ];
      symbolsFile = "${inputs.enthium}/linux/usr-share-X11-xkb-symbols-us";
    };

  };

}
