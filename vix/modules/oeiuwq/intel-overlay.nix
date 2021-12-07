{ lib, ... }: {
  nixpkgs.overlays = [ (new: old: { inherit (lib.mds.intelPkgs) pandoc niv; }) ];
}
