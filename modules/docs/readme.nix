# readme: README.md generated from live Ren data, written by `nix run .#write-files`.
{
  lib,
  ren,
  ...
}:
let
  # README parts: plain `_` files (import-tree skips them)
  vocab = import ./_vocabulary.nix;
  vocabDirs = import ./_vocabulary-dirs.nix;
  ir = import ./_fleet-ir.nix {
    inherit lib ren;
    chans = import ./_fleet-channels.nix;
  };
  map' = import ./_readme-map.nix { inherit ir; };
  # collapsed section; the blank line after </summary> lets GitHub render the markdown inside
  fold = summary: body: ''
    <details><summary>${summary}</summary>

    ${body}
    </details>
  '';
  intro = ''
    # vix

    Vic's machines, homes and dev envs in [Ren](https://github.com/vic/ren) (built on [Gen](https://github.com/sini/gen)), a re-take on [Den](https://github.com/denful/den).
    Generated file: edit `modules/docs/`, then run `nix run .#write-files`.
  '';
  commands = ''
    ## Commands

    ```sh
    nix build .#nixosConfigurations.frodo.config.system.build.toplevel
    nix build '.#homeConfigurations."vic@bitstream".activationPackage'
    nix run .#write-files                 # regenerate this README
    nix flake check                       # includes checks.x86_64-linux."files/README.md"
    nix eval --json .#ci.matrix           # every CI build job: host, mac, home, devshell
    ```
  '';
  history = ''
    - [Ren (current)](https://github.com/vic/vix/tree/ren)
    - [Den without flakes](https://github.com/vic/vix/tree/historic/den)
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
      (import ./_readme-tour.nix)
      commands
      map'.scopes
      (fold "Channels and class forwarding (diagrams)" map'.more)
      (fold "Vocabulary: kinds, classes, channels, profiles" (
        import ./_readme-vocab.nix { inherit ren vocab; }
      ))
      (fold "Directory structure" (import ./_readme-dirs.nix { inherit vocabDirs; }))
      (fold "Recipes: add a host, feature, env, ssh host, secret" (import ./_readme-recipes.nix))
      (fold "History" history)
    ];
    # the same graph as JSON, for tools: `nix build .#fleet-ir`
    packages =
      { system, ... }:
      {
        fleet-ir = system.legacyPackages.writeText "fleet-ir.json" (builtins.toJSON ir);
      };
  };
}
