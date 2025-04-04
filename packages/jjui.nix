{
  pname,
  inputs,
  pkgs,
}:
pkgs.buildGoModule rec {
  inherit pname;
  version = "0.8.2";
  src = inputs.jjui;
  vendorHash = "sha256-YlOK+NvyH/3uvvFcCZixv2+Y2m26TP8+ohUSdl3ppro=";
  meta.mainProgram = pname;
}
