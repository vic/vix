username := `whoami`
hostname := `hostname -s`
system := `nix-instantiate --raw --strict --eval -E builtins.currentSystem`

help:
  just -l

fmt *args:
  fmtt {{args}}

hm *args:
  {{username}}@{{hostname}} switch --ask {{args}}

build host=hostname *args:
  {{hostname}} build {{args}}

switch host=hostname *args:
  {{hostname}} switch --ask {{args}}

boot host=hostname *args:
  {{hostname}} boot --ask {{args}}

reboot host=hostname *args:
  just boot {{host}} --ask {{args}}
  reboot

ci test="" *args:
  nix-unit --expr "(import ./.).ci \"{{system}}\" \"{{test}}\"" {{args}}

