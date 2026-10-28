# readme tour: each sven construct vix uses, linked to the line that uses it.
let
  inherit (import ./_src.nix) src top;
  row = what: links: "| ${what} | ${builtins.concatStringsSep ", " links} |";
in
''
  ## A tour of sven, in vix

  sven has four words: kinds, scopes, aspects, sinks. Each row links to the line in vix that uses a construct.

  | sven | in vix |
  | --- | --- |
  ${builtins.concatStringsSep "\n" [
    (row "`sven.kinds.<k>`: typed data" [
      (src "platforms/nixos.nix" "sven.kinds.host = {" "host")
      (src "platforms/microvm.nix" "sven.kinds.guest = {" "guest")
      (src "platforms/darwin.nix" "sven.kinds.mac = {" "mac")
      (src "platforms/home-manager.nix" "sven.kinds.home = {" "home")
      (src "topology/people.nix" "sven.kinds.user = {" "user")
      (src "envs/env.nix" "sven.kinds.env = {" "env")
      (src "editors/vim.nix" "sven.kinds.vim = {" "vim")
    ])
    (row "fields and types" [
      (src "topology/machine.nix" "system = sven.kinds.system;" "a ref field")
      (src "topology/machine.nix" "channel = opt sven.kinds.channel" "opt (a default)")
      (src "topology/machine.nix" "wifi = maybe" "maybe (null)")
      (src "helpers.nix" "enum = xs: is" "listOf, attrsOf, enum")
      (src "topology/ssh-hosts.nix" "fwd = is" "is (any check)")
      (src "platforms/nixos.nix" "fields = sven.kinds.machine.fields;" "shared fields")
    ])
    (row "`derive`: a default computed from the instance" [
      (src "vic/dots.nix" "fields.checkout = sven.lib.derive" "checkout: from kind and users")
      (src "flake/ci.nix" "fields.runner = derive" "a system's runner: from the machines on it")
    ])
    (row "`sven.<k>.<name>`: an instance" [
      (src "hosts/frodo/default.nix" "sven.host.frodo = {" "sven.host.frodo")
      (src "hosts/home-bitstream.nix" "sven.home.bitstream = {" "sven.home.bitstream")
      (src "topology/people.nix" "sven.user.vic = {" "sven.user.vic")
      (src "envs/envs.nix" "sven.env.rustenv" "sven.env.rustenv")
      (src "vic/nvf/profiles.nix" "sven.vim.neovim = {" "sven.vim.neovim")
    ])
    (row "data kinds: instances no `spawns` reaches" [
      (src "topology/channel.nix" "sven.channel.unstable" "channel")
      (src "topology/secrets.nix" "sven.kinds.secret.fields" "secret")
      (src "topology/secrets.nix" "deploy = false;" "a secret only tools read")
      (src "topology/ssh-hosts.nix" "sven.kinds.ssh-host.fields" "ssh-host")
      (src "editors/emacs.nix" "sven.kinds.emacs.fields" "emacs")
      (src "topology/workspaces.nix" "sven.kinds.workspace.fields" "workspace")
    ])
    (row "`spawns`: the scope tree" [
      (src "topology/fleet.nix" "spawns = {" "fleet → system, host, mac, home")
      (src "platforms/nixos.nix" "spawns.user = sven.helpers.usersOf" "host → user")
      (src "platforms/microvm.nix" "sven.kinds.host.spawns.guest" "host → guest")
      (src "editors/vim.nix" "sven.kinds.system.spawns.vim" "system → vim")
      (src "envs/env.nix" "sven.kinds.user.spawns.env" "user → env")
    ])
    (row "`sven.aspects.<a>`: one feature" [
      (src "vic/vcs/git.nix" "sven.aspects.git = {" "git")
      (src "hardware/kvm.nix" "sven.aspects.kvm-amd = {" "kvm-amd")
      (src "topology/machine.nix" "sven.aspects.hostname = {" "hostname")
    ])
    (row "`at`: where an aspect is active" [
      (src "hosts/frodo/impermanence.nix" "at = sven.host.frodo;" "an instance")
      (src "flake/ci.nix" "at = sven.kinds.mac;" "a kind")
      (src "vic/vcs/git.nix" "at = sven.aspects.vic-headless;" "an aspect")
      (src "roles/roles.nix" "sven.aspects.graphical.at = [" "a list: any")
      (src "hosts/frodo/default.nix" "sven.aspects.trusted.at = sven.host.frodo;"
        "from many files: a union"
      )
      (src "vic/rdesk.nix" "at = [ ];" "nowhere")
    ])
    (row "roles from data: a fact test, no host file names them" [
      (src "hosts/ci-runner.nix" "(s: s.ghRunner != null)" "ci-runner: a ghRunner label")
      (src "roles/roles.nix" "sven.aspects.installer.at = all [" "installer: form iso")
      (src "forms/wsl.nix" "(s: s.form == \"wsl\")" "wsl: form wsl")
      (src "hosts/autoinclude.nix" "builtins.pathExists (./. + \"/\${s.name}/_nixos\")"
        "autoinclude: a hosts/<name>/_nixos dir"
      )
    ])
    (row "`all`, `not`, `within`, `has`, `same`, fact tests" [
      (src "roles/tiers.nix" "(not (within sven.aspects.installer))"
        "all [ vic-headless (not (within installer)) ]"
      )
      (src "platforms/microvm.nix" "(has sven.kinds.guest)" "has guest")
      (src "hardware/kvm.nix" "(s: s.cpu == \"amd\")" "s: s.cpu == \"amd\"")
      (src "platforms/microvm.nix" "same g.on h" "same g.on h")
    ])
    (row "sinks and their reduce" [
      (src "topology/fleet.nix" "sinks.out.reduce = sven.lib.reduce.merge;" "merge")
      (src "platforms/accounts.nix" "login-shells.reduce = sven.lib.reduce.set;" "set")
      (src "platforms/nixos.nix" "nixos.out =" "list (the default)")
      (src "flake/outputs.nix" "reduce = one;" "one: one formatter per system")
      (src "platforms/accounts.nix" "primary-user.reduce = sven.lib.reduce.one;" "one: one admin per mac")
      (src "platforms/ports.nix" "reduce = sven.lib.reduce.entries;" "entries: each value with its giver")
      (src "helpers.nix" "flat = {" "own reduce: flat (unique concat)")
      (src "platforms/impermanence.nix" "name = \"persist\";" "own reduce: persist (path union)")
    ])
    (row "typed sinks: `of` checks each element" [
      (src "topology/secrets.nix" "of = sven.helpers.listOf sven.kinds.secret;" "a list of secret refs")
      (src "vic/dots.nix" "of = sven.helpers.attrsOf (sven.lib.is (p: builtins.pathExists"
        "a dots path that exists"
      )
      (src "platforms/ports.nix" "of = sven.helpers.listOf (" "{ port; what; }")
    ])
    (row "forwards: a sink key names another sink" [
      (src "platforms/nixos.nix" "os.nixos = " "os → nixos")
      (src "platforms/microvm.nix" "nixos.nixos =" "guest nixos → host nixos")
      (src "platforms/nixos.nix" "os = { user, account" "account → os")
      (src "platforms/home-manager.nix" "os = { user, homeManager" "homeManager → os")
      (src "platforms/impermanence.nix" "sven.kinds.host.sinks.persist = {" "persist → nixos")
      (src "topology/secrets.nix" "sven.kinds.host.sinks.secrets = {" "host secrets → nixos (sops-nix)")
      (src "envs/env.nix" "sinks.env-packages.homeManager" "env-packages → homeManager")
      (src "editors/vim.nix" "sinks.nvf.packages" "nvf → packages")
      (src "nix/unfree.nix" "unfree = { user, unfree, ... }: unfree;" "user unfree → machine unfree")
    ])
    (row "`out`: flake outputs" [
      (src "platforms/nixos.nix" "nixosConfigurations.\${host.name}" "nixosConfigurations.<host>")
      (src "flake/outputs.nix" "ci.matrix" "ci.matrix")
      (src "agent/rdf.nix" "rdfPack =" "rdfPack")
      (src "topology/fleet.nix" "sven.flake = { out, ... }: out;" "sven.flake")
    ])
    (row "the `out` arg: an element reads the flake outputs, not `inputs.self`" [
      (src "packages/vic-edge.nix" "{ system, out, ... }:" "vic-edge wraps out.packages")
      (src "flake/ci-workflow.nix" "{ out, ... }:" "ci.yml from out.checks and out.ci.matrix")
    ])
    (row "a sink `at`: who may receive" [
      (src "platforms/home-manager.nix" "at = sven.aspects.on-linux;" "homeLinux on linux")
      (src "platforms/nixos.nix" "at = within sven.helpers.machines;" "account on machines")
    ])
    (row "walls: a sink with no keys keeps elements at its scope" [
      (src "topology/people.nix" "git-ignores = list;" "git-ignores")
      (src "nix/features.nix" "sven.kinds.host.sinks.nix-features = list;" "nix-features")
      (src "platforms/ports.nix" "sven.kinds.user.sinks.ports = sink // {" "ports (to served)")
    ])
    (row "args: a kind, a sink, `scope`" [
      (src "flake/ci.nix" "{ host, ... }:" "{ host, ... }")
      (src "envs/env.nix" "{ env, env-packages, ... }:" "{ env, env-packages, ... }")
      (src "topology/machine.nix" "os = { scope, ... }" "{ scope, ... }")
      (src "forms/wsl.nix" "{ primary-user, ... }:" "{ primary-user, ... }")
    ])
    (row "errors as data: an `errors` key gives error records, no throw" [
      (src "topology/secrets.nix" "sven.aspects.secret-files = {" "a secret file no instance owns")
      (src "topology/ssh-hosts.nix" "sven.aspects.ssh-jumps = {" "a proxyJump cycle")
      (src "flake/ci.nix" "sven.aspects.ci-runner-labels = {" "0 or 2+ runners on a system")
      (src "hosts/frodo/impermanence.nix" "errors =" "frodo wipeRoot guards")
      (src "platforms/accounts.nix" "two admins are an error record" "`one` with two admins")
    ])
    (row "`sven.helpers`: shared values" [
      (src "helpers.nix" "sven.helpers = {" "helpers")
      (src "helpers.nix" "place =" "place")
      (src "helpers.nix" "sopsSecrets =" "sopsSecrets")
    ])
    (row "flake-file: inputs per aspect" [
      (src "flake/flake-file.nix" "sven.aspects.vix-flake = {" "vix-flake")
      (src "envs/rust.nix" "flake-file.inputs.rust-overlay" "env-rust")
    ])
    (row "files: generated repo files" [
      (src "flake/files.nix" "sven.kinds.fleet.sinks.files.out" "the files sink")
      (src "docs/readme.nix" "files.file.\"README.md\"" "this README")
      (src "flake/ci-workflow.nix" "files.file.\".github/workflows/ci.yml\"" "ci.yml")
    ])
    (row "graphs (`sven.lib.graphs`)" [
      (src "topology/ssh-hosts.nix" "sven.lib.graphs.sccs jumps" "sccs: ssh jumps")
      (src "agent/invariants.nix" "sven.lib.graphs.transpose succ" "transpose, nodesOf: flake follows")
    ])
    (row "invariants: Datalog over the facts" [
      (src "agent/invariants.nix" "sven.invariants = {" "invariants")
      (src "agent/invariants.nix" "runners-no-users =" "runners-no-users")
      (src "agent/invariants.nix" "unique-port =" "unique-port")
      (src "agent/invariants.nix" "follows-declared =" "follows-declared")
    ])
    (row "stored queries and krn synthesis" [
      (src "agent/queries.nix" "sven.queries = {" "stored queries")
      (src "agent/queries.nix" "portsOf =" "portsOf")
      (src "agent/queries.nix" "unfreeOn =" "unfreeOn")
      (src "agent/synthesis.nix" "K.infd" "freePort: a krn finite domain")
      (src "vic/ai/headroom.nix" "ports = [" "a `ports` element")
    ])
    (row "trust labels and the knowledge pack" [
      (src "agent/labels.nix" "sven.labels = {" "labels by path")
      (src "agent/rdf.nix" "removeAttrs (sven.lib.rdf.share {" "rdf share (sha256)")
      (src "agent/rdf.nix" "sven.lib.rdf.shacl" "SHACL shapes")
    ])
    (row "stage and change programs" [
      (src "docs/_readme-recipes.nix" "op = \"new\"" "a change program")
      (top "mcp/test.sh" "call sven_stage" "stage a change")
      (top "mcp/test.sh" "call sven_program" "dry-run a program")
      (src "agent/mcp.nix" "sven.aspects.mcp-app = {" "the MCP app")
    ])
    (row "tests.nix: oracles over the eval result" [
      (top "tests.nix" "vix-permutation-stable =" "file order: reversed modules, same values")
      (top "tests.nix" "vix-sibling-laziness =" "laziness: a broken mac never reaches frodo")
      (top "tests.nix" "port-clash-fires =" "negative controls")
      (top "tests.nix" "fingerprints =" "e2e: settings fingerprint vs vix")
    ])
  ]}
''
