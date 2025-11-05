{ den, ... }:
{
  den.default.includes = [
    (den._.import-tree._.host ../nix/hosts)
  ];
}
