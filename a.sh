#!/bin/bash

# ==============================================================================
# My Dotfiles Setup Script
#
# This script automates the setup of my configuration files and tools.
# It performs the following actions:
#   1. Detects the Linux distribution (Fedora, Debian/Ubuntu, Arch).
#   2. Installs all necessary dependencies, including build tools and Xorg.
#   3. Uses GNU Stow to symlink configuration files into the correct locations.
#      - Links user configs to the $HOME directory.
#      - Links system-wide configs to the /etc directory using sudo.
#   4. Compiles and installs dwm and slock from the source in the repo.
#   5. Applies distribution-specific tweaks (e.g., for Fedora's bash files).
#
# Usage:
#   ./setup.sh
#
# ==============================================================================

# --- Color Definitions ---
# Regular Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Bold Colors
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'

# Background Colors (Less common for script output, but good to know)
BG_RED='\033[41m'
BG_GREEN='\033[42m'
# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to check if a command exists.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages using the globally defined INSTALL_CMD
install_packages() {
    # The eval is used to correctly execute the command string with arguments
    eval "$INSTALL_CMD $@"
}

# --- Main Logic ---

echo -e "${BLUE}🚀 Starting dotfiles setup...${NC}"

# Step 1: Detect OS and set the appropriate install command.
echo -e "${CYAN}> Detecting package manager...${NC}"
INSTALL_CMD=""
OS_ID=""

if command_exists dnf; then
    echo ">> Fedora detected. Using DNF."
    INSTALL_CMD="sudo dnf install -y"
    BUILD_DEPS_GROUP='@development-tools libX11-devel libXft-devel libXinerama-devel'
    OS_ID="fedora"
elif command_exists apt-get; then
    echo ">> Debian/Ubuntu based system detected. Using APT."
    sudo apt-get update
    INSTALL_CMD="sudo apt-get install -y"
    BUILD_DEPS_GROUP="build-essential libx11-dev libxft-dev libxinerama-dev"
    # Try to get OS_ID from /etc/os-release for tweaks later
    if [ -f /etc/os-release ]; then . /etc/os-release; OS_ID=$ID; fi
elif command_exists pacman; then
    echo ">> Arch Linux detected. Using Pacman."
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    BUILD_DEPS_GROUP="base-devel libx11 libxft libxinerama"
    OS_ID="arch"
else
    echo -e "${RED}⛔ ERROR: Could not find a known package manager (dnf, apt-get, pacman).${NC}"
    echo -e "${YELLOW}Please install dependencies manually and re-run this script.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Package manager configured.${NC}"

# Step 2: Install all dependencies
echo -e "${CYAN}> Installing all required dependencies...${NC}"
echo "  - Installing core tools..."
install_packages "git stow"

# Add Xorg server installation here
echo "  - Installing X.Org server..."
if [[ "$OS_ID" == "fedora" ]]; then
    install_packages "xorg-x11-server-Xorg"
elif [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then # Assuming common OS_ID for Debian/Ubuntu
    install_packages "xserver-xorg xinit" # xinit is crucial for startx
elif [[ "$OS_ID" == "arch" ]]; then
    install_packages "xorg-server xorg-xinit" # xorg-xinit for startx
fi

echo "  - Installing build tools for dwm/slock..."
install_packages $BUILD_DEPS_GROUP


echo "  - Installing desktop applications and utilities..."
install_packages "alacritty kitty neovim picom tmux waybar wofi feh xbindkeys"

# Hyprland installation is often more complex, but we'll try for distros where it's easy.
if [[ "$OS_ID" == "fedora" || "$OS_ID" == "arch" ]]; then
    install_packages "hyprland"
fi
echo -e "${GREEN}✅ Dependencies installed.${NC}"


# Step 3: Stow user-level configuration files (to $HOME)
echo -e "${CYAN}> Symlinking user configurations to $HOME...${NC}"
# Dynamically build the list of home packages using a loop.
HOME_PACKAGES=""
for dir in */; do
    # Remove the trailing slash from the directory name
    pkg_name="${dir%/}"

    # If the directory is 'etc', skip it. Add other exceptions here if needed.
    if [[ "$pkg_name" == "etc" ]]; then
        continue
    fi

    # Append the package name and a space to our list
    HOME_PACKAGES+="$pkg_name "
done

stow --adopt -R -t "$HOME" $HOME_PACKAGES
echo -e "${GREEN}✅ User dotfiles linked successfully.${NC}"


# Step 4: Stow system-level configuration files (to /etc)
echo -e "${CYAN}> Symlinking system-wide configurations to /etc...${NC}"
if [ -d "etc" ]; then
    sudo stow --adopt -R -t / etc
    echo -e "${GREEN}✅ System-wide configs linked successfully.${NC}"
else
    echo "> No 'etc' package found, skipping."
fi


# Step 5: Build and install Suckless tools (dwm, slock)
echo -e "${CYAN}> Compiling and installing Suckless tools (dwm, slock)...${NC}"
# Use a variable to avoid repeating the path. $HOME may not be set in some sudo envs.
SUCKLESS_CONFIG_DIR="$(eval echo ~"$USER")/.config"

if [ -d "$SUCKLESS_CONFIG_DIR/dwm" ]; then
    echo "  - Building dwm..."
    (cd "$SUCKLESS_CONFIG_DIR/dwm" && sudo make clean install)
    echo -e "${GREEN}✅ dwm installed.${NC}"
else
    echo -e "${YELLOW}> DWM source not found, skipping build.${NC}"
fi

if [ -d "$SUCKLESS_CONFIG_DIR/slock" ]; then
    echo "  - Building slock..."
    (cd "$SUCKLESS_CONFIG_DIR/slock" && sudo make clean install)
    echo -e "${GREEN}✅ slock installed.${NC}"
else
    echo -e "${YELLOW}> slock source not found, skipping build.${NC}"
fi


# Step 6: Apply distribution-specific tweaks
# echo "> Applying distribution-specific tweaks..."
# if [[ "$OS_ID" == "fedora" ]]; then
#     echo "  - Applying Fedora-specific bash configuration..."
#     if [ -f "$HOME/.bashrc_fedora" ]; then
#         ln -sf "$HOME/.bashrc_fedora" "$HOME/.bashrc"
#         echo "    Linked .bashrc_fedora to .bashrc"
#     fi
#     if [ -f "$HOME/.bash_profile_fedora" ]; then
#         ln -sf "$HOME/.bash_profile_fedora" "$HOME/.bash_profile"
#         echo "    Linked .bash_profile_fedora to .bash_profile"
#     fi
# else
#     echo "> No specific tweaks for this OS."
# fi


# --- Finalization ---
echo ""
echo -e "${YELLOW}🎉 All done! Your system is configured.${NC}" 
echo -e "${CYAN}Recommendations:${NC}"
echo "  - Please REBOOT or log out and log back in for all changes to take effect."
echo "  - For Neovim, you may need to open it and run :checkhealth or let the plugin manager install plugins."
