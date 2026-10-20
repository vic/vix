# release images: bootable ISO (bombadil) and WSL tarball (annatar), read back from the flake's own configs.
{ ren, inputs, ... }:
{
  ren.aspects.release-images = {
    at = ren.system.x86_64-linux;
    packages = { ... }: {
      bombadil-iso = inputs.self.nixosConfigurations.bombadil.config.system.build.isoImage;
      annatar-wsl = inputs.self.nixosConfigurations.annatar.config.system.build.tarballBuilder;
    };
  };
}
