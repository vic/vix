# readme: README.md generated from live Ren data, written by `nix run .#write-files`.
{
  ren,
  readmeTour,
  readmeVocab,
  readmeDirs,
  readmeRecipes,
  ...
}:
let
  intro = ''
    # vix

    Vic's machines, homes and dev envs, written in [Ren](https://github.com/vic/ren) (built on Gen).
    This file is generated. Edit `modules/docs/`, then run `nix run .#write-files`.
  '';
  commands = ''
    ## Commands

    ```sh
    nix build .#nixosConfigurations.frodo.config.system.build.toplevel
    nix build '.#homeConfigurations."vic@bitstream".activationPackage'
    nix run .#write-files                 # regenerate this README
    nix flake check                       # includes checks.x86_64-linux."files/README.md"
    nix eval --json .#ci.matrix              # every CI build job: host, mac, home, devshell
    ```
  '';
  history = ''
    ## History

    - Ren (current): this tree, branch `ren` — https://github.com/vic/vix/tree/ren
    - [Den without flakes (last Den commit)](https://github.com/vic/vix/tree/historic/den)
    - [Den with flakes + flake-parts](https://github.com/vic/vix/tree/historic/den-flake-parts)
    - [Dendritic flake-parts only](https://github.com/vic/vix/tree/historic/dendritic-flake-parts)
    - [blueprint](https://github.com/vic/vix/tree/historic/blueprint)
    - [flake-parts](https://github.com/vic/vix/tree/historic/flake-parts)
    - [old m1 flake](https://github.com/vic/vix/tree/historic/mk-darwin-system) with [mk-darwin-system](https://github.com/vic/mk-darwin-system)
    - other with snowfall-lib lost
  '';
in
{
  ren.aspects.readme = {
    at = ren.system.x86_64-linux;
    files.files.file."README.md".text = builtins.concatStringsSep "\n" [
      intro
      readmeTour
      readmeVocab
      readmeDirs
      readmeRecipes
      commands
      history
    ];
  };
}
