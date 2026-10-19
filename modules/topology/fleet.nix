# Root of the scope tree, and the systems machines are built for.
{
  ren,
  lib,
  opt,
  ...
}:
{
  ren.kinds.fleet.below = [
    ren.kinds.system
    ren.kinds.host
    ren.kinds.mac
    ren.kinds.home
  ];
  # scopes built per system: editor profiles (editors/vim.nix), dev environments (envs/env.nix)
  ren.kinds.system.below = [
    ren.kinds.vim
    ren.kinds.env
  ];
  ren.kinds.system.darwin = opt lib.types.bool false;

  ren.fleet.vix = { };
  ren.system.x86_64-linux = { };
  ren.system.aarch64-linux = { };
  ren.system.x86_64-darwin.darwin = true;
  ren.system.aarch64-darwin.darwin = true;
}
