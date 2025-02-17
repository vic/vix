{ pkgs, imports, ... }:
{

  import = [
    (
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
        home.file = envs;
      }
    )
  ];

  home.packages = with pkgs; [
    perSystem.devshell.default
    # devenv
  ];

  programs.direnv.enable = true;

  home.file.".envrc".text = ''
    export FLAKE=${inputs.self.outPath}
  '';

}
