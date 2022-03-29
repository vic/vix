.PHONY: all

all: fmt test install

test: flake-check fmt-check

fmt:
	find . -type f -iname "*.nix" -print0 | xargs -0 alejandra

fmt-check:
	find . -type f -iname "*.nix" -print0 | xargs -0 alejandra -c

flake-check:
	nix flake check

install:
	nix run

build:
	nix build

update:
	niv update
	nix flake update
