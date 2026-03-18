hostname := `hostname -s`
system := `nix-instantiate --raw --strict --eval -E builtins.currentSystem`

help:
  just -l

fmt *args:
  fmtt {{args}}

build host=hostname class="nixos" *args:
  nh os build --file . {{class}}Configurations.{{host}} {{args}}

switch host=hostname class="nixos" *args:
  nh os switch --file . {{class}}Configurations.{{host}} {{args}}
  
