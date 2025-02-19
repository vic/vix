{
  pname,
  pkgs,
  inputs,
}:
pkgs.buildGoModule rec {
  inherit pname;
  version = "0.3.2";
  src = inputs.cli-leader;
  vendorHash = "sha256-boMBnBXOKLs7W267xjWe5AM5QInvRugz7oAUagSLrHc=";
  postPatch = ''
    cp ${./leader}/go.* .
  '';
}
