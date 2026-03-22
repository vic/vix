hostname := `hostname -s`
system := `nix-instantiate --raw --strict --eval -E builtins.currentSystem`

help:
  just -l

fmt *args:
  fmtt {{args}}

build host=hostname *args:
  {{hostname}} build {{args}}

switch host=hostname *args:
  {{hostname}} switch {{args}}

boot host=hostname *args:
  {{hostname}} boot {{args}}

reboot host=hostname *args:
  just boot {{host}} {{args}}
  reboot
  
ci test="" *args:
  nix-unit --expr "(import ./.).ci \"{{system}}\" \"{{test}}\"" {{args}}
  
