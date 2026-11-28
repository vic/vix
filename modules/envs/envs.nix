# envs: vic's dev environments (ref-typed language kinds!).
{ yen, ... }:
{
  yen.env.nixenv.langs = [ yen.lang.nix ];
  yen.env.rustenv.langs = [
    yen.lang.rust
    yen.lang.c
  ];
  yen.env.goenv.langs = [ yen.lang.go ];
  yen.env.nodeenv.langs = [ yen.lang.node ];
  yen.env.pyenv.langs = [ yen.lang.python ];
  yen.env.fullenv.langs = [
    yen.lang.nix
    yen.lang.rust
    yen.lang.go
    yen.lang.node
    yen.lang.python
    yen.lang.c
  ];
}
