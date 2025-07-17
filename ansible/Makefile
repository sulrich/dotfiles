# Ansible Development Environment Setup
# Usage: make <target> HOST=hostname.example.com

# Default values
HOST ?= localhost
CONFIG ?= playbooks/vars/user-config.yml
INVENTORY ?= $(HOST),
PLAYBOOK ?= playbooks/setup-env-user-only.yml

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help setup check install-deps lint validate

help: ## Show this help message
	@echo "$(GREEN)Ansible Development Environment Setup$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make <target> HOST=hostname.example.com"
	@echo ""
	@echo "$(YELLOW)Targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-deps: ## Install ansible and dependencies
	@echo "$(YELLOW)Installing Ansible dependencies...$(NC)"
	uv venv ~/.venvs/ansible 2>/dev/null || true
	~/.venvs/ansible/bin/uv pip install ansible passlib

check: ## Dry run - show what would be changed
	@echo "$(YELLOW)Running dry-run against $(HOST)...$(NC)"
	ansible-playbook -i "$(INVENTORY)" $(PLAYBOOK) --check --diff

validate: ## Validate playbook syntax
	@echo "$(YELLOW)Validating playbook syntax...$(NC)"
	ansible-playbook $(PLAYBOOK) --syntax-check

lint: ## Lint playbook with ansible-lint
	@echo "$(YELLOW)Linting playbook...$(NC)"
	ansible-lint $(PLAYBOOK) || echo "$(RED)ansible-lint not installed or failed$(NC)"

setup: ## Run full setup on target host
	@echo "$(YELLOW)Running full setup on $(HOST)...$(NC)"
	ansible-playbook -i "$(INVENTORY)" $(PLAYBOOK)

setup-with-config: ## Run setup with custom configuration
	@echo "$(YELLOW)Running setup with config $(CONFIG) on $(HOST)...$(NC)"
	@test -f $(CONFIG) || (echo "$(RED)Config file $(CONFIG) not found$(NC)" && exit 1)
	ansible-playbook -i "$(INVENTORY)" -e @$(CONFIG) $(PLAYBOOK)

# Selective installations
setup-go: ## Install only Go
	ansible-playbook -i "$(INVENTORY)" $(PLAYBOOK) --tags "go"

setup-python: ## Install only Python tools
	ansible-playbook -i "$(INVENTORY)" $(PLAYBOOK) --tags "python"

setup-dotfiles: ## Setup only dotfiles
	ansible-playbook -i "$(INVENTORY)" $(PLAYBOOK) --tags "dotfiles"

setup-dev-tools: ## Install only development tools
	ansible-playbook -i "$(INVENTORY)" $(PLAYBOOK) --tags "development-tools"

# Multipass specific targets
multipass-setup: ## Setup multipass VMs
	ansible-playbook -i inventory/multipass.yaml playbooks/multipass-setup.yml

server-setup: ## Setup server account
	ansible-playbook -i inventory/multipass.yaml playbooks/server-acct-setup.yml

# Utility targets
create-config: ## Create user configuration from template
	@if [ ! -f playbooks/vars/user-config.yml ]; then \
		echo "$(YELLOW)Creating user configuration from template...$(NC)"; \
		cp playbooks/vars/user-config-template.yml playbooks/vars/user-config.yml; \
		echo "$(GREEN)Created playbooks/vars/user-config.yml - please edit it with your settings$(NC)"; \
	else \
		echo "$(YELLOW)Configuration file already exists at playbooks/vars/user-config.yml$(NC)"; \
	fi

clean: ## Clean up temporary files
	@echo "$(YELLOW)Cleaning up...$(NC)"
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Examples
example-local: ## Example: setup localhost
	@echo "$(GREEN)Example: Setting up localhost$(NC)"
	@echo "make setup HOST=localhost"

example-remote: ## Example: setup remote host
	@echo "$(GREEN)Example: Setting up remote host$(NC)"
	@echo "make setup HOST=myserver.example.com"

example-custom: ## Example: setup with custom config
	@echo "$(GREEN)Example: Setting up with custom configuration$(NC)"
	@echo "make create-config"
	@echo "# Edit playbooks/vars/user-config.yml"
	@echo "make setup-with-config HOST=myserver.example.com"
