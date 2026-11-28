# files: repo files generated via sini/files (`packages.x86_64-linux.write-files` + per-file checks).
{
  yen,
  reduce,
  inputs,
  ...
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  evalFiles =
    mods:
    inputs.nixpkgs.lib.evalModules {
      modules = [
        inputs.files.module
        {
          _module.args.pkgs = pkgs;
          files.root = inputs.self;
        }
      ]
      ++ mods;
    };
in
{
  yen.kinds.root.sinks.files = {
    reduce = reduce.modules;
    allowOrphan = true;
    into.out =
      { files, ... }:
      (e: {
        packages.x86_64-linux.write-files = e.config.files.writer.drv;
        checks.x86_64-linux = e.config.files.checks;
      })
        (evalFiles files);
  };

  yen.aspects.files-inputs = {
    at = yen.root;
    flake-file.inputs.files.url = "github:sini/files";
  };
}
