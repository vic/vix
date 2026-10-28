# Unfree: any scope allows unfree packages by name; each machine and home config accepts what its subtree allows.
{ sven, ... }:
let
  inherit (sven.lib.reduce) merge;
  accept =
    { unfree, lib, ... }:
    lib.mkIf (unfree != { }) {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) (builtins.attrNames unfree);
    };
in
{
  sven.kinds.host.sinks.unfree.reduce = merge;
  sven.kinds.mac.sinks.unfree.reduce = merge;
  sven.kinds.vim.sinks.unfree.reduce = merge; # a vim profile's plugins (editors/vim.nix)
  sven.kinds.user.sinks.unfree = {
    reduce = merge;
    # its own name: a user's names also reach the machine above it. `user` keeps one element per user.
    unfree = { user, unfree, ... }: unfree;
  };

  sven.aspects.unfree = {
    at = [
      sven.helpers.machines
      sven.kinds.user
    ];
    os = accept;
    homeManager = accept;
  };
}
