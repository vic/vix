{ lib, pkgs, vix, ... }: rec {

  linkJvm = (name: jdk:
    pkgs.runCommand "link-jvm-${name}" { } ''
      mkdir -p $out/Library/Java/JavaVirtualMachines
      ln -s ${builtins.toPath jdk} $out/Library/Java/JavaVirtualMachines/${name}
    '');

  shellDirenv = name: shell:
    pkgs.runCommand "${name}-shell-direnv" {
      shell_input_derivation = shell.inputDerivation;
    } (builtins.readFile ./shell-direnv.bash);

  nivSources = import "${vix}/nix/sources.nix";

  nivGoModule = { name, moduleOpts ? (meta: opts: opts) }:
    let
      src = nivSources."go-${name}";
      meta = {
        inherit name;
        description = name;
        version = src.version or src.rev;
      } // src;
    in (pkgs.buildGoModule (moduleOpts meta rec {
      inherit (meta) version;
      inherit src meta;
      pname = meta.name;
      name = "${pname}-${version}";
      vendorSha256 = meta.vendorSha256 or lib.fakeSha256;
    }));

  nivGoAutoMod = name:
    (nivGoModule {
      inherit name;
      moduleOpts = meta: opts:
        opts // {
          runVend = true;
          doCheck = false;
          overrideModAttrs = old: {
            buildPhase = ''
              go mod init ${
                meta.go_module or "github.com/${meta.owner}/${meta.repo}"
              }
              ${old.buildPhase}
            '';
            installPhase = ''
              ${old.installPhase}
              cp go.mod $out
            '';
          };
        };
    }).overrideAttrs (old: {
      buildPhase = ''
        cp vendor/go.mod .
        ${old.buildPhase}
      '';
    });

  nivFishPlugin = name: {
    inherit name;
    src = nivSources."fish-${name}";
  };

  vixLink = path: lib.mds.mkOutOfStoreSymlink "/hk/vix/${path}";

  nivApp = name:
    lib.mds.installNivDmg {
      inherit name;
      src = nivSources."${name}App";
    };

}
