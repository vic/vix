.PHONY: all nixfmt

all: nixfmt

nixfmt:
	find . -type f -iname "*.nix" -print0 | xargs -0 nixfmt

install:
	nix run .
