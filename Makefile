.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: bootstrap
bootstrap: ## Activate system on fresh MacOS.
	sudo rm -f /etc/nix/nix.conf && \
	env NIX_CONF_DIR="$(CURDIR)" nix run

.PHONY: update
update: ## Update flake inputs.
	nix flake update

.PHONY: install
install: ## Activate system
	nix run

.PHONY: test
test: ## Test system is installable.
	nix flake check
	nix run '.#format' -- --check .

.PHONY: format
format: ## Format all nix files.
	nix run '.#format' -- --quiet .
