# Kits and assemblies (yen.lib.batteries.kits). A kit is data: roles, a typed interface per role, constraints, the
# export keys it may give, the assemblies it adds. An assembly is one use of a kit: its `kit` is a ref, each role's
# machines an `at` predicate. Each machine spawns one `member` scope per (assembly, role) it takes; the member's
# elements go up to the machine. Library kits come from `yen.lib.kits`: import the module, write an assembly.
{ yen, lib, ... }:
let
  inherit (yen.lib) opt holds;
  kits = yen.lib.batteries.kits;
  attrs = yen.lib.attrs;
  # the assemblies and the parts their kits add (a part lives under its assembly)
  assemblies = kits.assemblies (lib.attrValues yen.assembly); # spawns read data
  # tree requests: every assembly, host and mac, with their data
  own.instances = yen.kinds.assembly;
  hosts.instances = yen.kinds.host;
  macs.instances = yen.kinds.mac;
  membersOf = kits.members { inherit assemblies holds; };
in
{
  yen.kinds.kit.fields = {
    roles = opt attrs { };
    constraints = opt attrs { };
    exports = opt (yen.lib.listOf yen.lib.str) [ ];
    adds = opt (yen.lib.is lib.isFunction) (_: { });
  };
  yen.kinds.assembly.fields = {
    kit = yen.kinds.kit;
    roles = opt attrs { };
  };
  yen.kinds.member = { }; # spawned under machines; its elements go up to the machine
  yen.kinds.host.spawns.member = membersOf;
  yen.kinds.mac.spawns.member = membersOf;

  # members write their own export element; a reader keeps the elements of one assembly and role (`yen.lib.same`)
  yen.kinds.fleet.sinks.exports.reduce = kits.exports { isMember = holds yen.kinds.member; };

  # the contract: a kit ref, known roles, `at` predicates, machine and assembly counts; typed settings per member
  yen.aspects.kits-contract = {
    at = yen.kinds.fleet;
    cycle =
      { tree, ... }:
      {
        tree = [
          own
          hosts
          macs
        ];
        errors = [
          (kits.contract {
            assemblies = kits.assemblies (tree.select own);
            machines = tree.select hosts ++ tree.select macs;
            inherit holds;
          })
        ];
      };
  };
  yen.aspects.kits-settings-typed = {
    at = yen.kinds.member;
    errors = kits.settings-typed;
  };
}
