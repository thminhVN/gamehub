.PHONY: dev setup deps server test deploy deploy-hot hooks push

# Start the Phoenix dev server (installs deps + sets up assets on first run)
dev: deps
	mix phx.server

# One-time project setup: deps, assets
setup:
	mix setup

# Install git hooks (run once after cloning)
hooks:
	git config core.hooksPath .githooks
	@echo "Git hooks installed — version will auto-bump on commits to main."

# Push to origin, ensuring the auto-bump hook is installed first so the
# version is bumped on commit. Commit your work before running this.
push: hooks
	git push

# Fetch Elixir dependencies
deps:
	mix deps.get

# Alias for the dev server without the deps check
server:
	mix phx.server

# Run the test suite
test:
	mix test

# VPS deploy: update the working tree to latest main, then run the deploy script
# (full release extract + restart — the only mode that refreshes static assets)
deploy:
	git checkout main
	git pull --ff-only origin main
	./deploy.sh

# VPS hot upgrade: no restart, live games keep their socket. Elixir-only changes
# ONLY — a hot upgrade cannot refresh assets/ or priv/static (see deploy.sh).
deploy-hot:
	git checkout main
	git pull --ff-only origin main
	./deploy.sh --hot
