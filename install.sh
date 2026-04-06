#!/usr/bin/env bash
# nCode saas-toolkit Base Installer
# https://github.com/dangogit/saas-toolkit
#
# Installs the base plugin + essential plugins and skills for all nCode students.
# Run the main Claude Code installer first: danielthegoldman.com/claude-code-installer

# -----------------------------------------
# Colors & helpers
# -----------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_step()       { echo -e "\n${CYAN}${BOLD}> $1${RESET}"; }
print_done()       { echo -e "  ${GREEN}[ok] $1${RESET}"; }
print_installing() { echo -e "  ${YELLOW}[..] $1...${RESET}"; }
print_error()      { echo -e "  ${RED}[!!] $1${RESET}"; }
print_info()       { echo -e "  ${CYAN}[i] $1${RESET}"; }

# -----------------------------------------
# Pre-flight check
# -----------------------------------------
if ! command -v claude &>/dev/null; then
  print_error "Claude Code is not installed."
  echo ""
  echo -e "  Run the Claude Code installer first:"
  echo -e "  ${BOLD}curl -fsSL https://danielthegoldman.com/claude-code/install.sh | bash${RESET}"
  echo ""
  exit 1
fi

# -----------------------------------------
# Welcome banner
# -----------------------------------------
echo ""
echo -e "${BOLD}${CYAN}+================================================+${RESET}"
echo -e "${BOLD}${CYAN}|     nCode saas-toolkit - Base Installer         |${RESET}"
echo -e "${BOLD}${CYAN}|  Skills, agents & plugins for SaaS development  |${RESET}"
echo -e "${BOLD}${CYAN}+================================================+${RESET}"
echo ""
echo -e "  This installer will set up:"
echo -e "  ${GREEN}+${RESET} saas-toolkit plugin (5 skills + 4 agents)"
echo -e "  ${GREEN}+${RESET} Superpowers plugin (brainstorming, planning, TDD, debugging)"
echo -e "  ${GREEN}+${RESET} Context7 plugin (library docs lookup)"
echo -e "  ${GREEN}+${RESET} TypeScript LSP plugin (TypeScript intelligence)"
echo -e "  ${GREEN}+${RESET} Frontend Design plugin (production-grade UI)"
echo ""
read -r -p "  Press Enter to continue, or Ctrl+C to cancel... "

# -----------------------------------------
# 1. saas-toolkit plugin
# -----------------------------------------
print_step "Installing saas-toolkit plugin"
print_installing "dangogit/saas-toolkit"
claude plugin add dangogit/saas-toolkit 2>/dev/null && \
  print_done "saas-toolkit installed" || \
  print_done "saas-toolkit already installed"

# -----------------------------------------
# 2. Superpowers plugin
# -----------------------------------------
print_step "Installing Superpowers plugin"
print_installing "superpowers (brainstorming, planning, debugging, TDD, code review)"
claude plugin add superpowers 2>/dev/null && \
  print_done "superpowers installed" || \
  print_done "superpowers already installed"

# -----------------------------------------
# 3. Context7 plugin
# -----------------------------------------
print_step "Installing Context7 plugin"
print_installing "context7 (library & framework docs lookup)"
claude plugin add context7 2>/dev/null && \
  print_done "context7 installed" || \
  print_done "context7 already installed"

# -----------------------------------------
# 4. TypeScript LSP plugin
# -----------------------------------------
print_step "Installing TypeScript LSP plugin"
print_installing "typescript-lsp (TypeScript intelligence)"
claude plugin add typescript-lsp 2>/dev/null && \
  print_done "typescript-lsp installed" || \
  print_done "typescript-lsp already installed"

# -----------------------------------------
# 5. Frontend Design plugin
# -----------------------------------------
print_step "Installing Frontend Design plugin"
print_installing "frontend-design (production-grade UI design)"
claude plugin add frontend-design 2>/dev/null && \
  print_done "frontend-design installed" || \
  print_done "frontend-design already installed"

# -----------------------------------------
# Done!
# -----------------------------------------
echo ""
echo -e "${BOLD}${GREEN}+================================================+${RESET}"
echo -e "${BOLD}${GREEN}|        Base toolkit ready!                      |${RESET}"
echo -e "${BOLD}${GREEN}+================================================+${RESET}"
echo ""
echo -e "  ${BOLD}What was installed:${RESET}"
echo -e "  saas-toolkit (5 skills + 4 agents)"
echo -e "  superpowers, context7, typescript-lsp, frontend-design"
echo ""
echo -e "  ${BOLD}Next: Install your track${RESET}"
echo -e "  ${CYAN}Web:${RESET}    curl -fsSL https://danielthegoldman.com/saas-toolkit-web/install.sh | bash"
echo -e "  ${CYAN}Mobile:${RESET} curl -fsSL https://danielthegoldman.com/saas-toolkit-mobile/install.sh | bash"
echo ""
