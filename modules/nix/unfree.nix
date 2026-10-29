# Unfree: any scope allows unfree packages by name; each machine and home config accepts what its subtree allows.
{ yen, ... }:
let
  inherit (yen.lib.reduce) merge;
  accept =
    { unfree, lib, ... }:
    lib.mkIf (unfree != { }) {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) (builtins.attrNames unfree);
    };
in
{
  yen.kinds.host.sinks.unfree.reduce = merge;
  yen.kinds.mac.sinks.unfree.reduce = merge;
  yen.kinds.vim.sinks.unfree.reduce = merge; # a vim profile's plugins (editors/vim.nix)
  yen.kinds.user.sinks.unfree = {
    reduce = merge;
    # its own name: a user's names also reach the machine above it. `user` keeps one element per user.
    unfree = { user, unfree, ... }: unfree;
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
