#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==============================================================================
# Ubuntu Nerd Font Installation Script
#
# This script automates the download, installation, and cache update
# for Ubuntu Mono Nerd Font (one of the popular choices for terminals).
#
# Usage:
#   ./install_ubuntu_nerdfont.sh
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to check if a command exists.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages (specific for apt, as this script targets Ubuntu)
install_apt_packages() {
    if command_exists apt-get; then
        echo "  - Installing required packages via apt..."
        sudo apt-get update && sudo apt-get install -y "$@"
    else
        echo -e "${RED}⛔ ERROR: apt-get not found. Cannot install dependencies.${NC}"
        exit 1
    fi
}

# --- Main Logic ---

echo -e "${BLUE}🚀 Starting Ubuntu Nerd Font installation...${NC}"

# Step 1: Check for necessary tools (wget, unzip)
echo -e "${CYAN}› Checking for required tools (wget, unzip)...${NC}"
install_apt_packages "wget" "unzip"

echo -e "${GREEN}✅ Required tools are present.${NC}"

# Step 2: Define font URL and destination
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip"
FONT_DIR="$HOME/.local/share/fonts/UbuntuMonoNerdFont"
FONT_ZIP="UbuntuMono.zip"

echo -e "${CYAN}› Creating font directory: ${FONT_DIR}${NC}"
mkdir -p "$FONT_DIR"

# Step 3: Download the font
echo -e "${CYAN}› Downloading Ubuntu Mono Nerd Font...${NC}"
if wget -O "/tmp/$FONT_ZIP" "$FONT_URL"; then
    echo -e "${GREEN}✅ Font downloaded successfully.${NC}"
else
    echo -e "${RED}⛔ ERROR: Failed to download font from ${FONT_URL}. Exiting.${NC}"
    exit 1
fi

# Step 4: Unzip the font
echo -e "${CYAN}› Unzipping font into ${FONT_DIR}...${NC}"
if unzip -o "/tmp/$FONT_ZIP" -d "$FONT_DIR"; then
    echo -e "${GREEN}✅ Font unzipped successfully.${NC}"
else
    echo -e "${RED}⛔ ERROR: Failed to unzip font to ${FONT_DIR}. Exiting.${NC}"
    exit 1
fi

# Step 5: Update font cache
echo -e "${CYAN}› Updating font cache...${NC}"
if fc-cache -fv; then
    echo -e "${GREEN}✅ Font cache updated.${NC}"
else
    echo -e "${YELLOW}Warning: Failed to update font cache. You may need to run 'fc-cache -fv' manually.${NC}"
fi

# Step 6: Clean up downloaded zip file
echo -e "${CYAN}› Cleaning up temporary files...${NC}"
rm -f "/tmp/$FONT_ZIP"
echo -e "${GREEN}✅ Cleanup complete.${NC}"

# --- Finalization ---
echo ""
echo -e "${YELLOW}🎉 Ubuntu Mono Nerd Font installed successfully!${NC}"
echo -e "${CYAN}Recommendations:${NC}"
echo "  - You may need to restart your terminal emulator (e.g., Alacritty, Kitty) or applications (e.g., Neovim) to see the new font."
echo "  - Configure your terminal/application to use 'UbuntuMono Nerd Font' (or 'UbuntuMono Nerd Font Mono')."
echo ""
