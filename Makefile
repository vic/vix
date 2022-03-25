.PHONY: test all

test: nixfmt-check

all: nixfmt build

nixfmt:
	find . -type f -iname "*.nix" -print0 | xargs -0 nixfmt

nixfmt-check:
	find . -type f -iname "*.nix" -print0 | xargs -0 nixfmt -c

install:
	nix run

build:
	nix build
