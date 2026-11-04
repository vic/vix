# Unfree: any scope allows unfree packages by name (`unfree = [ "name" ];`); each machine and home config accepts what
# its subtree allows, with one allowUnfreePredicate (the nixos.unfree battery: nixpkgs.config does not merge it).
{ yen, ... }:
let
  # an element is a list of package names; the reader gets them unique, first-seen order
  names = {
    reduce = yen.lib.reduce.flat;
    of = yen.lib.listOf yen.lib.str;
  };
  accept = yen.lib.batteries.nixos.unfree { from = yen.kinds.user.sinks.unfree; }; # reads the `unfree` sink of the scope
in
{
  yen.kinds.host.sinks.unfree = names;
  yen.kinds.guest.sinks.unfree = names;
  yen.kinds.mac.sinks.unfree = names;
  yen.kinds.vim.sinks.unfree = names; # a vim profile's plugins (editors/vim.nix)
  # its own name: a user's names also reach the machine above it
  yen.kinds.user.sinks.unfree = names // {
    unfree = { unfree, ... }: unfree;
  };

  yen.aspects.unfree = {
    at = [
      yen.helpers.machines
      yen.kinds.user
    ];
    os = accept;
    homeManager = accept;
  };
}
