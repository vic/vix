# release images: bootable ISO (bombadil) and WSL tarball (annatar), read back from the flake's own configs.
{ yen, ... }:
{
  yen.aspects.release-images = {
    at = yen.system.x86_64-linux;
    packages =
      { out, ... }:
      {
        bombadil-iso = out.nixosConfigurations.bombadil.config.system.build.isoImage;
        annatar-wsl = out.nixosConfigurations.annatar.config.system.build.tarballBuilder;
      };
  };
}
