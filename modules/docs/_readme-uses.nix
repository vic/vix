# readme: how vix uses each yen capability. One row each: what it is, what vix does with it, a checked link.
let
  inherit (import ./_src.nix) src top;
  row =
    what: is: how: links:
    "| ${what} | ${is} | ${how} | ${builtins.concatStringsSep ", " links} |";
in
''
  ## How vix uses yen

  Each row is one yen capability: what it is, and the vix configuration it carries. The links point at the line.

  | Capability | What it is | How vix uses it | Where |
  | --- | --- | --- | --- |
  ${builtins.concatStringsSep "\n" [
    (row "Typed fields" "Each field of a kind has a type. A wrong value is an error record with `near`."
      "Machine facts are enums: `cpu`, `gpu`, `form`, `desktops`, `layouts`. Hardware aspects key on them."
      [ (src "topology/machine.nix" "desktops = opt" "desktops") ]
    )
    (row "Derived fields (`derive`)"
      "A field default that the instance computes from itself. An explicit value wins."
      "`checkout` for every machine with users. `cpu` and `gpu` from the facter report. The CI runner label of each system."
      [
        (src "vic/dots.nix" "yen.kinds.machine.fields.checkout = yen.lib.derive" "checkout")
        (src "topology/machine.nix" "cpu = derive" "cpu from facter")
        (src "flake/ci.nix" "yen.kinds.system.fields.runner = derive" "runner")
      ]
    )
    (row "Data kinds" "A kind that no kind spawns. Its instances have no scope; refs to them work."
      "Secrets, ssh hosts, workspaces and channels are data that aspects read."
      [
        (src "topology/secrets.nix" "yen.kinds.secret.fields" "secret")
        (src "topology/workspaces.nix" "yen.kinds.workspace.fields" "workspace")
      ]
    )
    (row "Structure from data (`spawns`)" "A scope's children come from a function of the data."
      "Each workspace becomes a microvm guest on frodo. Home nargun lives under host nargun."
      [
        (src "topology/workspaces.nix" "yen.guest = lib.mapAttrs" "guests from workspaces")
        (src "platforms/home-manager.nix" "yen.kinds.host.spawns.home" "home on host")
      ]
    )
    (row "Walls" "A sink with no keys. Elements stop there and go no higher."
      "A home under a host walls every host sink, so vic's home never changes nargun's NixOS."
      [ (src "platforms/home-manager.nix" "sinks = lib.genAttrs [" "home walls") ]
    )
    (row "Aspects and predicates (`at`)"
      "An aspect is active where its `at` holds: kinds, instances, aspect refs, `all`, `not`, `within`, `has`."
      "The tiers (`vic-headless`, `vic-gui`, `vic-full`, `vic-secrets`) gate every feature of vic."
      [ (src "roles/tiers.nix" "vic-gui" "tiers") ]
    )
    (row "Roles from data" "An aspect whose `at` is a fact about the instance."
      "A machine with a `ghRunner` label is a CI runner: one aspect for bill, tom and bert."
      [ (src "hosts/ci-runner.nix" "ghRunner != null" "ci-runner") ]
    )
    (row "Own reduce" "A sink reduce is any function of `[ { from; value; } ]`."
      "claude settings are ranked layers (rank 1 wins per key). List sinks keep first-seen order (`flat`). Permissions are sorted."
      [
        (src "vic/ai/claude.nix" "layers = {" "layers")
        (src "helpers.nix" "flat = {" "flat")
        (src "topology/people.nix" "sorted = {" "sorted")
      ]
    )
    (row "`one` reduce" "Exactly one element, or an error record."
      "The primary user of a mac and the WSL default user. Two admins are an error, not a silent pick."
      [
        (src "platforms/accounts.nix" "reduce.one" "primary-user")
        (src "forms/wsl.nix" "primary-user" "wsl")
      ]
    )
    (row "`entries` reduce" "Each value comes with the scope that gave it."
      "Ports go up to the fleet `served` sink with their scope. The vini tunnel forwards what runs on bitstream."
      [
        (src "platforms/ports.nix" "yen.kinds.fleet.sinks.served.reduce" "served")
        (src "vic/sys/ssh.nix" "forwardsServedBy" "tunnel forwards")
      ]
    )
    (row "Forwards" "A sink key feeds another sink, at the receiver."
      "A user's ports feed the fleet. A guest's NixOS goes into its host's `microvm.vms`."
      [
        (src "platforms/ports.nix" "served = { ports" "ports to served")
        (src "platforms/microvm.nix" "microvm.vms.\${guest.name}" "guest to host")
      ]
    )
    (row "The cycle form" "A component that asks the tree for data and gives 0 to n elements."
      "The microvm host asks for its guest scopes and gives one network setup for them."
      [ (src "platforms/microvm.nix" "children = yen.kinds.guest" "vm-host") ]
    )
    (row "The `out` arg" "An element reads the flake outputs lazily."
      "Release images, the CI workflow and the claude MCP entry read built outputs, not `inputs.self`."
      [
        (src "packages/release-images.nix" "out.nixosConfigurations.bombadil" "release images")
        (src "agent/mcp.nix" "out.apps." "yen-mcp in claude")
      ]
    )
    (row "Errors as data" "An aspect key `errors` gives error records. Evaluation continues."
      "frodo's wipeRoot guards, secret files that no instance owns, CI runner labels, sharedPkgs groups."
      [
        (src "topology/secrets.nix" "secret-files" "secret-files")
        (src "flake/ci.nix" "ci-runner-labels" "runner labels")
        (src "platforms/nixos.nix" "shared-pkgs-group" "shared pkgs")
      ]
    )
    (row "Autoinclude" "Files found by path become modules: no line in the host file."
      "`hosts/<name>/_nixos` holds each machine's hardware, disko and facter report."
      [ (src "hosts/autoinclude.nix" "builtins.pathExists (./. +" "autoinclude") ]
    )
    (row "Exports" "A scope outside any machine sends its content to a flake output."
      "`homeModules.vic`: vic's headless home for other flakes."
      [ (src "platforms/exports.nix" "output = \"homeModules\";" "homeModules.vic") ]
    )
    (row "Flake inputs per aspect" "Each aspect declares the inputs it uses. `flake.nix` is generated."
      "microvm, disko, impermanence, sops-nix and the skill inputs live with their users."
      [ (src "platforms/microvm.nix" "flake-file.inputs.microvm" "microvm input") ]
    )
    (row "Generated files" "The `files` sink writes files and checks that they are current."
      "README.md and the CI workflow."
      [ (src "flake/ci-workflow.nix" ".github/workflows/ci.yml" "ci.yml") ]
    )
    (row "Invariants" "Datalog rules over the fleet's facts. A true `bad:` atom is a violation."
      "Guest addresses and service ports are unique, every `follows` names a declared input, runners have no users."
      [
        (src "agent/invariants.nix" "unique-guest-addr =" "unique-guest-addr")
        (src "agent/invariants.nix" "follows-declared" "follows-declared")
      ]
    )
    (row "Stored queries and krn"
      "A named question on the eval result. krn synthesizes values that meet constraints."
      "`portsOf` a machine, and `freePort` picks a port that no service of the host uses."
      [
        (src "agent/queries.nix" "portsOf =" "portsOf")
        (src "agent/synthesis.nix" "freePort" "freePort")
      ]
    )
    (row "Graphs" "Reachability, cycles and layers over successor maps."
      "The ssh proxyJump graph: a jump cycle is an error."
      [ (src "topology/ssh-hosts.nix" "sccs" "ssh jumps") ]
    )
    (row "Trust labels" "Content gets the trust of the files that declare it."
      "Files that agents write get a lower trust, so their routed elements are easy to list."
      [ (src "agent/labels.nix" "yen.labels" "labels") ]
    )
    (row "Knowledge pack" "The eval result as N-Triples with a sha256, and SHACL shapes."
      "`out.rdfPack` for quipu, one snapshot per revision."
      [ (src "agent/rdf.nix" "rdfPack" "rdfPack") ]
    )
    (row "Infra checks" "Facts from fleet data, compared with each built system."
      "Hostname, keyd, nvidia, enthium and persisted directories, per host."
      [ (src "checks/infra.nix" "yen.aspects.infra-facts" "infra") ]
    )
    (row "Eval cost levers" "Shared pkgs per channel and system; a trimmed NixOS module list."
      "Ready for every host, off on all: enabling them needs the drvPath oracles on each host."
      [
        (src "platforms/nixos.nix" "sharedPkgs = opt" "sharedPkgs")
        (src "platforms/nixos.nix" "shared-pkgs-no-docs" "docs off")
      ]
    )
    (row "MCP server" "Agents ask the fleet over stdio JSON-RPC."
      "vic's claude sessions have the `yen` MCP server for this fleet."
      [ (src "agent/mcp.nix" "yen-mcp-claude" "claude entry") ]
    )
    (row "CI gate" "One eval per PR: no error records, invariants ok, no undefined aspect."
      "The `yen-gate` job of the generated workflow."
      [ (src "flake/ci-workflow.nix" "yen-gate" "yen-gate") ]
    )
    (row "Tests" "Checks over the eval result itself."
      "File order changes no result; a broken varda never stops frodo."
      [ (top "tests.nix" "vix-permutation-stable" "file order") ]
    )
  ]}
''
