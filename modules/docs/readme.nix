# readme: README.md generated from live Ren data, written by `nix run .#write-files`.
{
  ren,
  readmeVocab,
  readmeRecipes,
  ...
}:
let
  intro = ''
    # vix

    Vic's machines and homes as one Nix flake: NixOS hosts, nix-darwin macs and
    standalone home-manager homes, all built from the same features.
    Generated from the live configuration: edit `modules/docs/`, then `nix run .#write-files`.

    ## How Ren evaluates vix

    `outputs = inputs: inputs.ren.lib.mkFlake inputs (inputs.import-tree ./modules);`

    1. **Kinds** declare typed data; `ren.<kind>.<name>` are instances.
    2. Kinds with `below` form a scope tree: the fleet holds systems, hosts, macs and homes;
       systems hold envs; machines and homes hold their users.
    3. **Aspects** activate where their `at` predicate holds (`and anyOf not when within has`).
    4. Each aspect key names a **class** (module config) or a **channel** (data emission).
    5. Classes turn collected modules into flake outputs; channels fold emissions to receivers.

    ```nix
    ren.host.frodo = { system = ren.system.x86_64-linux; users = [ ren.user.vic ]; form = "laptop"; };
    ren.aspects.direnv = {
      at = vicAt.headless; # every scope where user vic lives
      homeManager.programs.direnv.enable = true;
    };
    ```
  '';
  commands = ''
    ## Commands

    ```sh
    nix build .#nixosConfigurations.frodo.config.system.build.toplevel
    nix build '.#homeConfigurations."vic@bitstream".activationPackage'
    nix run .#write-files                 # regenerate this README
    nix flake check                       # includes checks.x86_64-linux."files/README.md"
    # CI matrix: every nixos host, evaluated
    for h in $(nix eval --raw .#nixosConfigurations --apply 'c: toString (builtins.attrNames c)'); do
      nix eval --raw ".#nixosConfigurations.$h.config.system.build.toplevel.drvPath"
    done
    ```
  '';
in
{
  ren.aspects.readme = {
    at = ren.system.x86_64-linux;
    files.files.file."README.md".text = builtins.concatStringsSep "\n" [
      intro
      readmeVocab
      readmeRecipes
      commands
    ];
  };
}
