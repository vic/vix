# Live fleet catalog pages: Machines & Homes, Dev Envs & Neovim Profiles, Secrets & SSH.
{ yen, ... }:
let
  b = builtins;
  d = yen.helpers.vixDocs;

  allHosts = {
    instances = yen.kinds.host;
  };
  allMacs = {
    instances = yen.kinds.mac;
  };
  allHomes = {
    instances = yen.kinds.home;
  };
  allEnvs = {
    instances = yen.kinds.env;
  };
  allVims = {
    instances = yen.kinds.vim;
  };
  allSecrets = {
    instances = yen.kinds.secret;
  };
  sortNames = xs: b.sort (x: y: x.name < y.name) xs;
  optRef = r: if r == null then "—" else "`${r.name}`";
  refList = xs: if xs == [ ] then "—" else b.concatStringsSep ", " (map (x: "`${x.name}`") xs);
  boolMark = v: if v then "yes" else "no";
in
{
  yen.docPage.machines = {
    title = "Machines & Homes";
    section = yen.docSection.fleet;
    order = 10;
    summary = "Live catalog of every NixOS host, macOS machine, CI runner, and standalone home computed from the Vix fleet.";
  };

  yen.aspects.doc-fleet-machines = {
    at = yen.docPage.machines;
    cycle =
      { tree, ... }:
      (hosts: macs: homes: {
        tree = [
          allHosts
          allMacs
          allHomes
        ];
        docBody = ''
          Every row below is computed directly from `yen.host.*`, `yen.mac.*`, and `yen.home.*` via `tree.select`.
          Each host file only declares concrete facts — zero module imports and zero string tags.

          ## NixOS hosts (${toString (b.length hosts)})

          ${d.table
            [
              "Host"
              "System"
              "Form"
              "CPU / GPU"
              "Desktops"
              "Trusted"
              "Activate"
            ]
            (
              map (h: [
                "`${h.name}`"
                "`${h.system.name}`"
                (optRef h.form)
                "${optRef h.cpu} / ${optRef h.gpu}"
                (refList h.desktops)
                (boolMark h.trusted)
                "`sudo nixos-rebuild switch --flake .#${h.name}`"
              ]) hosts
            )
          }

          ## macOS machines (${toString (b.length macs)})

          ${d.table [ "Mac" "System" "Workstation" "Trusted" "Activate" ] (
            map (m: [
              "`${m.name}`"
              "`${m.system.name}`"
              (boolMark m.workstation)
              (boolMark m.trusted)
              "`sudo darwin-rebuild switch --flake .#${m.name}`"
            ]) macs
          )}

          ## Standalone homes (${toString (b.length homes)})

          Standalone homes set `wall = true` so OS sinks never leak upward onto a host.

          ${d.table [ "Home" "System" "Parent host" "Graphical" "Trusted" "Activate" ] (
            map (h: [
              "`${h.name}`"
              "`${h.system.name}`"
              (optRef h.on)
              (boolMark h.graphical)
              (boolMark h.trusted)
              "`home-manager switch --flake .#${h.user.name}@${h.name}`"
            ]) homes
          )}

          ## Example host file (`frodo`)

          Notice how concise a real NixOS laptop stays when roles and hardware modules match facts automatically:

          ${d.file ../hosts/frodo/default.nix "modules/hosts/frodo/default.nix"}

          Next, inspect all dev shells and Neovim profiles in [Dev Envs & Neovim Profiles](/fleet/envs-and-editors/).
        '';
      })
        (sortNames (tree.select allHosts))
        (sortNames (tree.select allMacs))
        (sortNames (tree.select allHomes));
  };

  yen.docPage.envs-and-editors = {
    title = "Dev Envs & Neovim Profiles";
    section = yen.docSection.fleet;
    order = 20;
    summary = "Live catalog of Vix's 6 language devShells and 5 ref-typed NVF Neovim profiles.";
  };

  yen.aspects.doc-fleet-envs = {
    at = yen.docPage.envs-and-editors;
    cycle =
      { tree, ... }:
      (envs: vims: {
        tree = [
          allEnvs
          allVims
        ];
        docBody = ''
          Vix defines dev environments (`yen.env.*`) and Neovim distributions (`yen.vim.*`) as first-class Yen kinds.
          Both spawn under `system` to become flake `devShells` and `packages`, and `env` also spawns under `user` whenever a host lists `envs = [ yen.env.rustenv ];`.

          ## Dev environments (${toString (b.length envs)})

          Every language is a typed `yen.lang.*` ref declared in `modules/envs/langs.nix`.

          ${d.table [ "DevShell" "Languages" "Enter shell" ] (
            map (e: [
              "`${e.name}`"
              (refList e.langs)
              "`nix develop .#${e.name}`"
            ]) envs
          )}

          ## Neovim profiles (${toString (b.length vims)})

          Every plugin feature is a typed `yen.vimFeature.*` ref checked at eval time.
          Aspects in `modules/vic/nvf/` match profiles via `yen.helpers.vimHas yen.vimFeature.<name>`.

          ${d.table [ "Profile" "Theme" "GUI" "Features" "Run" ] (
            map (v: [
              "`${v.name}`"
              (if v.theme == null then "default" else "`${v.theme}`")
              (boolMark v.gui)
              (toString (b.length v.features))
              "`nix run .#${v.name}`"
            ]) vims
          )}

          Query the exact features and NVF aspects active on any profile from your shell:

          ${d.sh ''
            nix eval --json .#yen.ask.featuresOf --apply 'f: f { vim = "nvim"; }'
            nix eval --json .#yen.ask.featuresOf --apply 'f: f { vim = "lazyvim"; }'
          ''}

          Next, see how Vix models encrypted secrets and SSH graphs in [Secrets & SSH Topology](/fleet/secrets-and-ssh/).
        '';
      })
        (sortNames (tree.select allEnvs))
        (sortNames (tree.select allVims));
  };

  yen.docPage.secrets-and-ssh = {
    title = "Secrets & SSH Topology";
    section = yen.docSection.fleet;
    order = 30;
    summary = "Model SOPS secrets as typed refs with orphan checks, and detect SSH ProxyJump cycles with `yen.graphs.cycles`.";
  };

  yen.aspects.doc-fleet-secrets = {
    at = yen.docPage.secrets-and-ssh;
    cycle =
      { tree, ... }:
      (secrets: {
        tree = [ allSecrets ];
        docBody = ''
          ## Secrets as typed data (`yen.secret.*`)

          Features request the secrets they need by emitting typed refs into a user or host `secrets` sink (`secrets = [ yen.secret.groq-api-key ];`).
          Three checks keep secret deployment tight:

          1. **No orphan files:** `secret-files` in `modules/topology/secrets.nix` returns a structured error if any encrypted file under `modules/vic/secrets/` lacks a matching `yen.secret.*` declaration.
          2. **Trusted places only:** the Datalog invariant `secrets-need-trusted` fails closed if any feature routes a secret onto an untrusted host or standalone home.
          3. **Tool-only secrets:** marking `deploy = false` keeps recovery or rotation secrets off every machine while keeping them tracked in the schema.

          ${d.table [ "Secret" "Format" "Deployed to machines" ] (
            map (s: [
              "`${s.name}`"
              (if s.format == null then "yaml" else "`${s.format.name}`")
              (boolMark s.deploy)
            ]) secrets
          )}

          ## SSH topology and cycle detection

          Each `yen.ssh-host.*` instance generates a `programs.ssh` match block, and `forwardsServedBy` automatically turns a home's declared `ports` into local SSH forwards (`10000 + port`).
          A ${d.cyclejs} aspect (`ssh-jumps` in `modules/topology/ssh-hosts.nix`) runs `yen.lib.graphs.cycles` across all `proxyJump` hops so a routing loop fails closed before deployment.

          Next, inspect every invariant, reactive guard, and CLI query in [Invariants & Live Queries](/verify/invariants-and-queries/).
        '';
      })
        (sortNames (tree.select allSecrets));
  };
}
