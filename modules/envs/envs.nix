# envs: vic's dev environments.
{ ... }:
{
  yen.env.nixenv.langs = [ "nix" ];
  yen.env.rustenv.langs = [
    "rust"
    "c"
  ];
  yen.env.goenv.langs = [ "go" ];
  yen.env.nodeenv.langs = [ "node" ];
  yen.env.pyenv.langs = [ "python" ];
  yen.env.fullenv.langs = [
    "nix"
    "rust"
    "go"
    "node"
    "python"
    "c"
  ];
}
