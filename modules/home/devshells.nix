{
  pkgs,
  imports,
  inputs,
  perSystem,
  ...
}:
let

  envs =
    with pkgs.lib;
    mergeAttrsList (
      map (
        name:
        setAttrByPath [ ".cache/envs/${name}/.envrc" "text" ] "use flake ${inputs.self.outPath}#${name}"
      ) (attrNames inputs.self.devShells.${pkgs.system})
    );
in
{

  imports = [
    inputs.use_devshell_toml.homeModules.default
    { home.file = envs; }
  ];

  home.packages = with pkgs; [
    perSystem.devshell.default
    # devenv
  ];

  home.file.".envrc".text = ''
    export FLAKE="$HOME/.flake"
  '';

}
