# Workspaces: one per purpose; each becomes an isolated claude guest on frodo (frodo-guests.nix).
{ lib, ... }:
{
  ren.kinds.workspace.repo = lib.types.str; # data kind: host path, shared into its guest at the same path

  ren.workspace.gen.repo = "/home/vic/hk/gen";
  ren.workspace.dnx.repo = "/home/vic/hk/dnx";
}
