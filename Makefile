# WinAssistAI - Cross-Platform Makefile
# Universal build and launch commands for all environments

.PHONY: help start start-full test-voice list-commands install-serenade setup clean
.DEFAULT_GOAL := help

# Colors for output (if supported)
CYAN = \033[96m
GREEN = \033[92m
YELLOW = \033[93m
RESET = \033[0m

# Detect available runtimes
NODE_EXISTS := $(shell command -v node 2>/dev/null)
PYTHON_EXISTS := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)
BASH_EXISTS := $(shell command -v bash 2>/dev/null)

# Choose the best available launcher
ifdef NODE_EXISTS
    LAUNCHER = node win_assist_ai.js
    RUNTIME = Node.js
else ifdef PYTHON_EXISTS
    LAUNCHER = python3 win_assist_ai.py 2>/dev/null || python win_assist_ai.py
    RUNTIME = Python
else ifdef BASH_EXISTS
    LAUNCHER = ./win_assist_ai.sh
    RUNTIME = Bash
else
    LAUNCHER = echo "Error: No compatible runtime found. Please install Node.js, Python, or ensure Bash is available."
    RUNTIME = None
endif

help: ## Show this help message
	@echo "$(CYAN)WinAssistAI - Universal Cross-Platform Launcher$(RESET)"
	@echo ""
	@echo "$(GREEN)Detected Runtime: $(RUNTIME)$(RESET)"
	@echo "$(GREEN)Launcher Command: $(LAUNCHER)$(RESET)"
	@echo ""
	@echo "$(YELLOW)Available Commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Examples:$(RESET)"
	@echo "  make start-full    # Launch with full Serenade integration"
	@echo "  make test-voice    # Test voice functionality"
	@echo "  make setup         # Make shell script executable"
	@echo ""

start: ## Start WinAssistAI with auto-detection
	@echo "$(GREEN)Starting WinAssistAI with $(RUNTIME)...$(RESET)"
	@$(LAUNCHER)

start-full: ## Start with full Serenade integration (recommended)
	@echo "$(GREEN)Starting WinAssistAI with full Serenade integration...$(RESET)"
	@$(LAUNCHER) --start-full

test-voice: ## Test text-to-speech functionality
	@echo "$(YELLOW)Testing voice functionality...$(RESET)"
	@$(LAUNCHER) --test-voice

list-commands: ## List all available WinAssistAI commands
	@echo "$(CYAN)Listing all available commands...$(RESET)"
	@$(LAUNCHER) --list-commands

with-serenade: ## Force launch with Serenade integration
	@echo "$(GREEN)Starting with Serenade integration...$(RESET)"
	@$(LAUNCHER) --with-serenade

no-serenade: ## Launch without Serenade integration
	@echo "$(YELLOW)Starting without Serenade integration...$(RESET)"
	@$(LAUNCHER) --no-serenade

install-serenade: ## Install Serenade voice control
	@echo "$(CYAN)Installing Serenade voice control...$(RESET)"
	@$(LAUNCHER) --install-serenade

version: ## Show version information
	@echo "$(CYAN)Version information:$(RESET)"
	@$(LAUNCHER) --version

setup: ## Make shell script executable and check dependencies
	@echo "$(YELLOW)Setting up WinAssistAI...$(RESET)"
	@chmod +x win_assist_ai.sh 2>/dev/null || echo "Note: chmod not available on this system"
	@echo "$(GREEN)Checking dependencies:$(RESET)"
	@echo -n "  Node.js: "
	@if command -v node >/dev/null 2>&1; then echo "$(GREEN)✓ Available$(RESET)"; else echo "$(YELLOW)✗ Not found$(RESET)"; fi
	@echo -n "  Python: "
	@if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then echo "$(GREEN)✓ Available$(RESET)"; else echo "$(YELLOW)✗ Not found$(RESET)"; fi
	@echo -n "  Bash: "
	@if command -v bash >/dev/null 2>&1; then echo "$(GREEN)✓ Available$(RESET)"; else echo "$(YELLOW)✗ Not found$(RESET)"; fi
	@echo -n "  PowerShell: "
	@if command -v powershell.exe >/dev/null 2>&1 || command -v pwsh >/dev/null 2>&1; then echo "$(GREEN)✓ Available$(RESET)"; else echo "$(YELLOW)✗ Not found$(RESET)"; fi
	@echo ""
	@echo "$(GREEN)Setup complete! You can now use 'make start-full' to launch.$(RESET)"

clean: ## Clean up temporary files
	@echo "$(YELLOW)Cleaning up temporary files...$(RESET)"
	@rm -f *.log 2>/dev/null || echo "No log files to clean"
	@echo "$(GREEN)Cleanup complete!$(RESET)"

# NPM-style aliases
npm-start: start-full ## NPM-style start command
npm-test: test-voice ## NPM-style test command
npm-run-help: help ## NPM-style help command

# Platform-specific shortcuts
windows: ## Windows-specific launch using batch file
	@echo "$(GREEN)Launching WinAssistAI using Windows batch file...$(RESET)"
	@cmd.exe /c WinAssistAI.bat

powershell: ## Launch directly with PowerShell
	@echo "$(GREEN)Launching WinAssistAI with PowerShell...$(RESET)"
	@powershell.exe -ExecutionPolicy Bypass -File "./scripts/start-with-serenade.ps1"

git-bash: ## Git Bash specific launch (force Node.js or Python)
	@echo "$(GREEN)Launching WinAssistAI for Git Bash...$(RESET)"
	@if command -v node >/dev/null 2>&1; then \
		node win_assist_ai.js --start-full; \
	elif command -v python3 >/dev/null 2>&1; then \
		python3 win_assist_ai.py --start-full; \
	elif command -v python >/dev/null 2>&1; then \
		python win_assist_ai.py --start-full; \
	else \
		echo "$(YELLOW)Please install Node.js or Python for Git Bash compatibility$(RESET)"; \
	fi

# Development shortcuts
dev: ## Development mode - list commands and test voice
	@echo "$(CYAN)Development mode - Running diagnostics...$(RESET)"
	@$(LAUNCHER) --test-voice
	@echo ""
	@$(LAUNCHER) --list-commands

debug: ## Debug mode - show system info and launcher details
	@echo "$(CYAN)Debug Information:$(RESET)"
	@echo "Operating System: $$(uname -s 2>/dev/null || echo 'Windows')"
	@echo "Shell: $$SHELL"
	@echo "Runtime: $(RUNTIME)"
	@echo "Launcher: $(LAUNCHER)"
	@echo "Working Directory: $$(pwd)"
	@echo "WinAssistAI Directory: $$(ls -la win_assist_ai.* 2>/dev/null || echo 'Files not found')"
	@echo ""
	@make setup

# Quick reference
quick-start: start-full ## Quick start alias
run: start ## Run alias
launch: start-full ## Launch alias
voice: test-voice ## Voice test alias
commands: list-commands ## Commands list alias