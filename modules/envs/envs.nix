# envs: vic's dev environments.
{ ... }:
{
  sven.env.nixenv.langs = [ "nix" ];
  sven.env.rustenv.langs = [
    "rust"
    "c"
  ];
  sven.env.goenv.langs = [ "go" ];
  sven.env.nodeenv.langs = [ "node" ];
  sven.env.pyenv.langs = [ "python" ];
  sven.env.fullenv.langs = [
    "nix"
    "rust"
    "go"
    "node"
    "python"
    "c"
  ];
}
