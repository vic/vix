{ pkgs, lib, vix-lib, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      vix-dots = vix-lib.mkOutOfStoreSymlink "/hk/dots";

      google-cloud-sdk_bla = let
        now = super.google-cloud-sdk.overrideAttrs (old: {
          src = if pkgs.system != "aarch64-darwin" then
            old.src
          else
            pkgs.fetchurl {
              url =
                "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-347.0.0-darwin-arm.tar.gz";
              sha256 =
                "1196c980ccc465272f6aa48a6b2e5a0ee6b255a20ad73654cea007813d1ccd99";
            };
          meta = old.meta // {
            platforms = old.meta.platforms ++ [ "aarch64-darwin" ];
          };
        });
      in now;

      # See https://github.com/NixOS/nixpkgs/pull/129543/files
      neovim = super.neovim-unwrapped;

    })
  ];
}
