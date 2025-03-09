# Vic's Nix Environment

```bash
# previously setup keys for secrets.

git clone git@github.com:vic/vix
cd vix
ln -sfn $PWD $HOME/.flake # Used to link config files (nvim/doom-emacs/terminals,etc)
nix develop -c os-rebuild <hostname> switch
```
