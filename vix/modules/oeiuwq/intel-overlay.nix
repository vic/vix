{ lib
, pkgs
, ...
}:
{
  nixpkgs.overlays = [
    # (new: old: { inherit (lib.mds.intelPkgs) pandoc niv; })
    # https://github.com/LnL7/nix-darwin/issues/417
    (
      new:
      old:
      {
        haskellPackages =
          old.haskellPackages.override
            {
              overrides =
                self:
                super:
                let
                  workaround140774 =
                    hpkg: with pkgs.haskell.lib; overrideCabal hpkg ( drv: { enableSeparateBinOutput = false; } );
                in
                { niv = workaround140774 super.niv; };
            };
      }
    )
  ];
}
