# readme tour: each yen construct vix uses, linked to the line that uses it.
let
  inherit (import ./_src.nix) src top;
  row = what: links: "| ${what} | ${builtins.concatStringsSep ", " links} |";
in
''
  ## A tour of yen, in vix

  yen has four words: kinds, scopes, aspects, sinks. Each row links to the line in vix that uses a construct.

  | yen | in vix |
  | --- | --- |
  ${builtins.concatStringsSep "\n" [
    (row "`yen.kinds.<k>`: typed data" [
      (src "platforms/nixos.nix" "yen.kinds.host = {" "host")
      (src "platforms/microvm.nix" "yen.kinds.guest = {" "guest")
      (src "platforms/darwin.nix" "yen.kinds.mac = {" "mac")
      (src "platforms/home-manager.nix" "yen.kinds.home = {" "home")
      (src "topology/people.nix" "yen.kinds.user = {" "user")
      (src "envs/env.nix" "yen.kinds.env = {" "env")
      (src "editors/vim.nix" "yen.kinds.vim = {" "vim")
    ])
    (row "fields and types" [
      (src "topology/machine.nix" "system = yen.kinds.system;" "a ref field")
      (src "topology/machine.nix" "channel = opt yen.kinds.channel" "opt (a default)")
      (src "topology/machine.nix" "wifi = maybe" "maybe (null)")
      (src "helpers.nix" "enum = xs: is" "listOf, attrsOf, enum")
      (src "topology/ssh-hosts.nix" "fwd = is" "is (any check)")
      (src "platforms/nixos.nix" "fields = yen.kinds.machine.fields;" "shared fields")
    ])
    (row "`derive`: a default computed from the instance" [
      (src "vic/dots.nix" "fields.checkout = yen.lib.derive" "checkout: from kind and users")
      (src "flake/ci.nix" "fields.runner = derive" "a system's runner: from the machines on it")
    ])
    (row "`yen.<k>.<name>`: an instance" [
      (src "hosts/frodo/default.nix" "yen.host.frodo = {" "yen.host.frodo")
      (src "hosts/home-bitstream.nix" "yen.home.bitstream = {" "yen.home.bitstream")
      (src "topology/people.nix" "yen.user.vic = {" "yen.user.vic")
      (src "envs/envs.nix" "yen.env.rustenv" "yen.env.rustenv")
      (src "vic/nvf/profiles.nix" "yen.vim.neovim = {" "yen.vim.neovim")
    ])
    (row "data kinds: instances no `spawns` reaches" [
      (src "topology/channel.nix" "yen.channel.unstable" "channel")
      (src "topology/secrets.nix" "yen.kinds.secret.fields" "secret")
      (src "topology/secrets.nix" "deploy = false;" "a secret only tools read")
      (src "topology/ssh-hosts.nix" "yen.kinds.ssh-host.fields" "ssh-host")
      (src "editors/emacs.nix" "yen.kinds.emacs.fields" "emacs")
      (src "topology/workspaces.nix" "yen.kinds.workspace.fields" "workspace")
    ])
    (row "`spawns`: the scope tree" [
      (src "topology/fleet.nix" "spawns = {" "fleet → system, host, mac, home")
      (src "platforms/nixos.nix" "spawns.user = yen.helpers.usersOf" "host → user")
      (src "platforms/microvm.nix" "yen.kinds.host.spawns.guest" "host → guest")
      (src "editors/vim.nix" "yen.kinds.system.spawns.vim" "system → vim")
      (src "envs/env.nix" "yen.kinds.user.spawns.env" "user → env")
    ])
    (row "`yen.aspects.<a>`: one feature" [
      (src "vic/vcs/git.nix" "yen.aspects.git = {" "git")
      (src "hardware/kvm.nix" "yen.aspects.kvm-amd = {" "kvm-amd")
      (src "topology/machine.nix" "yen.aspects.hostname = {" "hostname")
    ])
    (row "`at`: where an aspect is active" [
      (src "hosts/frodo/impermanence.nix" "at = yen.host.frodo;" "an instance")
      (src "flake/ci.nix" "at = yen.kinds.mac;" "a kind")
      (src "vic/vcs/git.nix" "at = yen.aspects.vic-headless;" "an aspect")
      (src "roles/roles.nix" "yen.aspects.graphical.at = [" "a list: any")
      (src "hosts/frodo/default.nix" "yen.aspects.trusted.at = yen.host.frodo;"
        "from many files: a union"
      )
      (src "vic/rdesk.nix" "at = [ ];" "nowhere")
    ])
    (row "roles from data: a fact test, no host file names them" [
      (src "hosts/ci-runner.nix" "(s: s.ghRunner != null)" "ci-runner: a ghRunner label")
      (src "roles/roles.nix" "yen.aspects.installer.at = all [" "installer: form iso")
      (src "forms/wsl.nix" "(s: s.form == \"wsl\")" "wsl: form wsl")
      (src "hosts/autoinclude.nix" "builtins.pathExists (./. + \"/\${s.name}/_nixos\")"
        "autoinclude: a hosts/<name>/_nixos dir"
      )
    ])
    (row "`all`, `not`, `within`, `has`, `same`, fact tests" [
      (src "roles/tiers.nix" "(not (within yen.aspects.installer))"
        "all [ vic-headless (not (within installer)) ]"
      )
      (src "platforms/microvm.nix" "(has yen.kinds.guest)" "has guest")
      (src "hardware/kvm.nix" "(s: s.cpu == \"amd\")" "s: s.cpu == \"amd\"")
      (src "platforms/microvm.nix" "same g.on h" "same g.on h")
    ])
    (row "sinks and their reduce" [
      (src "topology/fleet.nix" "sinks.out.reduce = yen.lib.reduce.merge;" "merge")
      (src "platforms/accounts.nix" "login-shells.reduce = yen.lib.reduce.set;" "set")
      (src "platforms/nixos.nix" "nixos.out =" "list (the default)")
      (src "flake/outputs.nix" "reduce = one;" "one: one formatter per system")
      (src "platforms/accounts.nix" "primary-user.reduce = yen.lib.reduce.one;" "one: one admin per mac")
      (src "platforms/ports.nix" "reduce = yen.lib.reduce.entries;" "entries: each value with its giver")
      (src "helpers.nix" "flat = {" "own reduce: flat (unique concat)")
      (src "platforms/impermanence.nix" "name = \"persist\";" "own reduce: persist (path union)")
    ])
    (row "typed sinks: `of` checks each element" [
      (src "topology/secrets.nix" "of = yen.helpers.listOf yen.kinds.secret;" "a list of secret refs")
      (src "vic/dots.nix" "of = yen.helpers.attrsOf (yen.lib.is (p: builtins.pathExists"
        "a dots path that exists"
      )
      (src "platforms/ports.nix" "of = yen.helpers.listOf (" "{ port; what; }")
    ])
    (row "forwards: a sink key names another sink" [
      (src "platforms/nixos.nix" "os.nixos = " "os → nixos")
      (src "platforms/microvm.nix" "nixos.nixos =" "guest nixos → host nixos")
      (src "platforms/nixos.nix" "os = { user, account" "account → os")
      (src "platforms/home-manager.nix" "os = yen.lib.batteries.home-manager.into-host" "homeManager → os")
      (src "platforms/impermanence.nix" "yen.kinds.host.sinks.persist = {" "persist → nixos")
      (src "topology/secrets.nix" "yen.kinds.host.sinks.secrets = {" "host secrets → nixos (sops-nix)")
      (src "envs/env.nix" "sinks.env-packages.homeManager" "env-packages → homeManager")
      (src "editors/vim.nix" "sinks.nvf.packages" "nvf → packages")
      (src "nix/unfree.nix" "unfree = { user, unfree, ... }: unfree;" "user unfree → machine unfree")
    ])
    (row "`out`: flake outputs" [
      (src "platforms/nixos.nix" "nixosConfigurations.\${host.name}" "nixosConfigurations.<host>")
      (src "flake/outputs.nix" "ci.matrix" "ci.matrix")
      (src "agent/rdf.nix" "rdfPack =" "rdfPack")
      (src "topology/fleet.nix" "yen.flake = { out, ... }: out;" "yen.flake")
    ])
    (row "the `out` arg: an element reads the flake outputs, not `inputs.self`" [
      (src "packages/vic-edge.nix" "{ system, out, ... }:" "vic-edge wraps out.packages")
      (src "flake/ci-workflow.nix" "{ out, ... }:" "ci.yml from out.checks and out.ci.matrix")
    ])
    (row "a sink `at`: who may receive" [
      (src "platforms/home-manager.nix" "at = yen.aspects.on-linux;" "homeLinux on linux")
      (src "platforms/nixos.nix" "at = within yen.helpers.machines;" "account on machines")
    ])
    (row "walls: a sink with no keys keeps elements at its scope" [
      (src "topology/people.nix" "git-ignores = list;" "git-ignores")
      (src "nix/features.nix" "yen.kinds.host.sinks.nix-features = list;" "nix-features")
      (src "platforms/ports.nix" "yen.kinds.user.sinks.ports = sink // {" "ports (to served)")
    ])
    (row "args: a kind, a sink, `scope`" [
      (src "flake/ci.nix" "{ host, ... }:" "{ host, ... }")
      (src "envs/env.nix" "{ env, env-packages, ... }:" "{ env, env-packages, ... }")
      (src "platforms/home-manager.nix" "nixos = { scope, ... }" "{ scope, ... }")
      (src "forms/wsl.nix" "{ primary-user, ... }:" "{ primary-user, ... }")
    ])
    (row "errors as data: an `errors` key gives error records, no throw" [
      (src "topology/secrets.nix" "yen.aspects.secret-files = {" "a secret file no instance owns")
      (src "topology/ssh-hosts.nix" "yen.aspects.ssh-jumps = {" "a proxyJump cycle")
      (src "flake/ci.nix" "yen.aspects.ci-runner-labels = {" "0 or 2+ runners on a system")
      (src "hosts/frodo/impermanence.nix" "errors =" "frodo wipeRoot guards")
      (src "platforms/accounts.nix" "two admins are an error record" "`one` with two admins")
    ])
    (row "`yen.helpers`: shared values" [
      (src "helpers.nix" "yen.helpers = {" "helpers")
      (src "helpers.nix" "place =" "place")
      (src "helpers.nix" "sopsSecrets =" "sopsSecrets")
    ])
    (row "flake-file: inputs per aspect" [
      (src "flake/flake-file.nix" "yen.aspects.vix-flake = {" "vix-flake")
      (src "envs/rust.nix" "flake-file.inputs.rust-overlay" "env-rust")
    ])
    (row "files: generated repo files" [
      (src "flake/files.nix" "yen.kinds.fleet.sinks.files.out" "the files sink")
      (src "docs/readme.nix" "files.file.\"README.md\"" "this README")
      (src "flake/ci-workflow.nix" "files.file.\".github/workflows/ci.yml\"" "ci.yml")
    ])
    (row "graphs (`yen.lib.graphs`)" [
      (src "topology/ssh-hosts.nix" "yen.lib.graphs.sccs jumps" "sccs: ssh jumps")
      (src "agent/invariants.nix" "yen.lib.graphs.transpose succ" "transpose, nodesOf: flake follows")
    ])
    (row "invariants: Datalog over the facts" [
      (src "agent/invariants.nix" "yen.invariants = {" "invariants")
      (src "agent/invariants.nix" "runners-no-users =" "runners-no-users")
      (src "agent/invariants.nix" "unique-port =" "unique-port")
      (src "agent/invariants.nix" "follows-declared =" "follows-declared")
    ])
    (row "stored queries and krn synthesis" [
      (src "agent/queries.nix" "yen.queries = {" "stored queries")
      (src "agent/queries.nix" "portsOf =" "portsOf")
      (src "agent/queries.nix" "unfreeOn =" "unfreeOn")
      (src "agent/synthesis.nix" "K.infd" "freePort: a krn finite domain")
      (src "vic/ai/headroom.nix" "ports = [" "a `ports` element")
    ])
    (row "trust labels and the knowledge pack" [
      (src "agent/labels.nix" "yen.labels = {" "labels by path")
      (src "agent/rdf.nix" "removeAttrs (yen.lib.rdf.share {" "rdf share (sha256)")
      (src "agent/rdf.nix" "yen.lib.rdf.shacl" "SHACL shapes")
    ])
    (row "stage and change programs" [
      (src "docs/_readme-recipes.nix" "op = \"new\"" "a change program")
      (top "mcp/test.sh" "call yen_stage" "stage a change")
      (top "mcp/test.sh" "call yen_program" "dry-run a program")
      (src "agent/mcp.nix" "yen.aspects.mcp-app = {" "the MCP app")
    ])
    (row "tests.nix: oracles over the eval result" [
      (top "tests.nix" "vix-permutation-stable =" "file order: reversed modules, same values")
      (top "tests.nix" "vix-sibling-laziness =" "laziness: a broken mac never reaches frodo")
      (top "tests.nix" "port-clash-fires =" "negative controls")
      (top "tests.nix" "fingerprints =" "e2e: settings fingerprint vs vix")
    ])
  ]}
''
