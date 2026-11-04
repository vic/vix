# kit github-runner: a machine that is a bare GitHub Actions runner. Role `runner`, setting `label` (the `runs-on` label).
# A member claims its system's runner on the fleet `runners` sink (one owner per system, flake/ci.nix) and makes its
# machine a bare runner with no users. A host file takes the role with one assembly.
{ yen, ... }:
let
  inherit (yen.lib) all same below;
  member = all [
    yen.kinds.member
    (s: same (s.kit or null) yen.kit.github-runner)
  ];
in
{
  yen.kit.github-runner.roles.runner.interface.label.type = yen.lib.str;
  yen.kit.github-runner.aspects.runner = {
    at = member;
    runners =
      { member, scope, ... }:
      {
        system = scope.parent.system.name;
        machine = scope.parent.name;
        inherit (member.settings) label;
      };
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
      fileSystems."/".fsType = "auto";
      users.users.runner.isNormalUser = true;
    };
    darwin = {
      users.users.runner.home = "/Users/runner";
      system.primaryUser = "runner";
    };
  };
  # the role of a machine that holds a runner member: the invariants and the docs read it
  yen.aspects.ci-runner.at = all [
    yen.helpers.machines
    (below member)
  ];
}
