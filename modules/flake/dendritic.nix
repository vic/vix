{ inputs, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.default
    inputs.den.flakeModule
  ];

  flake-file.inputs = {
    den.url = "github:vic/den";
    flake-file.url = "github:vic/flake-file";
    flake-aspects.url = "github:vic/flake-aspects";
    import-tree.url = "github:vic/import-tree";
    with-inputs.url = "github:vic/with-inputs";
    with-inputs.flake = false;
  };

}
