# readme tour: each Ren keyword once, linked to the line in vix that uses it.
let
  # `src file needle text`: a link to the first line of modules/<file> that contains needle.
  # The line is found at eval time, so links follow edits; a needle that is gone is an eval error.
  src =
    file: needle: text:
    let
      lines = builtins.filter builtins.isString (
        builtins.split "\n" (builtins.readFile (../. + "/${file}"))
      );
      has = l: builtins.replaceStrings [ needle ] [ "" ] l != l; # literal substring, no regex
      hits = builtins.filter (i: has (builtins.elemAt lines i)) (
        builtins.genList (i: i) (builtins.length lines)
      );
    in
    if hits == [ ] then
      throw "docs/_readme-tour.nix: `${needle}` not found in modules/${file}"
    else
      "[`${text}`](modules/${file}#L${toString (builtins.head hits + 1)})";
in
''
  ## A tour

  | Ren | in vix |
  | --- | --- |
  | `ren.kinds.<k>` | typed data: ${src "platforms/nixos.nix" "ren.kinds.host = {" "host"}, ${
    src "platforms/home-manager.nix" "ren.kinds.home = {" "home"
  }, ${src "topology/people.nix" "ren.kinds.user = {" "user"}, ${
    src "envs/env.nix" "ren.kinds.env.langs" "env"
  } |
  | `ren.<k>.<name>` | an instance: ${src "hosts/frodo.nix" "ren.host.frodo = {" "ren.host.frodo"}, ${
    src "people/vic.nix" "ren.user.vic = {" "ren.user.vic"
  }, ${src "envs/envs.nix" "ren.env.rustenv" "ren.env.rustenv"} |
  | `below`, `spawns` | the scope tree: ${
    src "platforms/nixos.nix" "below = [ ren.kinds.user ]" "host → user"
  }, ${src "platforms/microvm.nix" "ren.kinds.host.below" "host → guest"}, ${
    src "editors/vim.nix" "ren.kinds.system.below" "system → vim"
  } |
  | `is` | subkinds: ${src "platforms/nixos.nix" "is = ren.kinds.machine" "a host is a machine"}, ${
    src "platforms/microvm.nix" "is = ren.kinds.host" "a guest is a host"
  } |
  | `ren.aspects.<a>` | one feature: ${src "vic/vcs/git.nix" "ren.aspects.git = {" "git"}, ${
    src "community/kvm-amd.nix" "ren.aspects.kvm-amd = {" "kvm-amd"
  }, ${src "people/vic.nix" "ren.aspects.vic-gui" "vic-gui"} |
  | `at` | where an aspect is on: ${
    src "vic/shell/fish.nix" "at = ren.aspects.vic-headless" "at = ren.aspects.vic-headless"
  } |
  | `includes`, `excludes` | add or drop aspects below a scope: ${
    src "hosts/frodo.nix" "includes = [" "frodo includes its hardware"
  }, ${src "hosts/frodo-guests.nix" "excludes = ren.aspects.frodo.includes" "its guests exclude it"} |
  | `ren.classes.<c>` | a module system an aspect key feeds: ${
    src "platforms/nixos.nix" "ren.classes.nixos" "nixos"
  }, ${src "editors/vim.nix" "ren.classes.vim" "vim"} |
  | `into` | how a class builds: ${
    src "platforms/nixos.nix" "nixosConfigurations.$" "nixosConfigurations.<host>"
  } |
  | `ren.channels.<c>` | data a feature emits for a receiver: ${
    src "vic/vcs/git.nix" "ren.channels.git-ignores" "git-ignores"
  }, ${src "features/checks.nix" "ren.channels.checks" "checks"} |
  | `fold`, `to` | how a channel merges, and who reads it: ${
    src "features/checks.nix" "fold = ren.lib.fold.attrs" "checks folds attrs into the fleet"
  } |
  | `and`, `anyOf`, `not`, `within`, `has`, `when` | predicates for `at` and `to`: ${
    src "community/kvm-amd.nix" "cpu == \"amd\"" "when (s: s.host.cpu == \"amd\")"
  } |
  | `same` | identity: ${
    src "platforms/microvm.nix" "ren.lib.same g.on" "a guest runs on the host it names in on"
  } |
''
