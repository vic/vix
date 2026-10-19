# envs: vic's dev environments.
{ ... }:
{
  ren.env.nixenv.langs = [ "nix" ];
  ren.env.rustenv.langs = [
    "rust"
    "c"
  ];
  ren.env.goenv.langs = [ "go" ];
  ren.env.nodeenv.langs = [ "node" ];
  ren.env.pyenv.langs = [ "python" ];
  ren.env.fullenv.langs = [
    "nix"
    "rust"
    "go"
    "node"
    "python"
    "c"
  ];
}
