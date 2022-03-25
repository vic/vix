.PHONY: all

all: nixfmt update test build install

test: flake-check nixfmt-check

nixfmt:
	find . -type f -iname "*.nix" -print0 | xargs -0 nixfmt

nixfmt-check:
	find . -type f -iname "*.nix" -print0 | xargs -0 nixfmt -c

flake-check:
	nix flake check

install:
	nix run

build:
	nix build

update:
	niv update
	nix flake update
