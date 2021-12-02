intelPkgs: {
  nixpkgs.overlays = [(new: old: {
    inherit (intelPkgs) pandoc;
  })];
}
