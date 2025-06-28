#!/bin/bash

# ==============================================================================
# My Dotfiles Setup Script
#
# This script automates the setup of my configuration files and tools.
# It performs the following actions:
#   1. Detects the Linux distribution (Fedora, Debian/Ubuntu, Arch).
#   2. Installs all necessary dependencies, including build tools.
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

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to check if a command exists.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages using the globally defined INSTALL_CMD
install_package() {
    # The eval is used to correctly execute the command string with arguments
    eval "$INSTALL_CMD \"$1\""
}

# --- Main Logic ---

echo "🚀 Starting dotfiles setup..."

# Step 1: Detect OS and set the appropriate install command.
echo "› Detecting package manager..."
INSTALL_CMD=""
OS_ID=""

if command_exists dnf; then
    echo "›› Fedora detected. Using DNF."
    INSTALL_CMD="sudo dnf install -y"
    OS_ID="fedora"
elif command_exists apt-get; then
    echo "›› Debian/Ubuntu based system detected. Using APT."
    sudo apt-get update
    INSTALL_CMD="sudo apt-get install -y"
    # Try to get OS_ID from /etc/os-release for tweaks later
    if [ -f /etc/os-release ]; then . /etc/os-release; OS_ID=$ID; fi
elif command_exists pacman; then
    echo "›› Arch Linux detected. Using Pacman."
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    OS_ID="arch"
else
    echo "⛔ ERROR: Could not find a known package manager (dnf, apt-get, pacman)."
    echo "Please install dependencies manually and re-run this script."
    exit 1
fi
echo "✅ Package manager configured."


# Step 2: Install all dependencies
echo "› Installing all required dependencies..."
echo "  - Installing core tools..."
install_package "git"
install_package "stow"

echo "  - Installing build tools for dwm/slock..."
# The variable needs to be expanded without quotes here

echo "  - Installing desktop applications and utilities..."
install_package "alacritty"
install_package "kitty"
install_package "neovim"
install_package "picom"
install_package "tmux"
install_package "waybar"
install_package "wofi"
install_package "feh"
install_package "xbindkeys"

# Hyprland installation is often more complex, but we'll try for distros where it's easy.
if [[ "$OS_ID" == "fedora" || "$OS_ID" == "arch" ]]; then
    install_package "hyprland"
fi
echo "✅ Dependencies installed."


# Step 3: Stow user-level configuration files (to $HOME)
echo "› Symlinking user configurations to $HOME..."
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

stow -R -t "$HOME" $HOME_PACKAGES
echo "✅ User dotfiles linked successfully."


# Step 4: Stow system-level configuration files (to /etc)
echo "› Symlinking system-wide configurations to /etc..."
if [ -d "etc" ]; then
    sudo stow -R -t / etc
    echo "✅ System-wide configs linked successfully."
else
    echo "› No 'etc' package found, skipping."
fi


# Step 5: Build and install Suckless tools (dwm, slock)
echo "› Compiling and installing Suckless tools (dwm, slock)..."
# Use a variable to avoid repeating the path. $HOME may not be set in some sudo envs.
SUCKLESS_CONFIG_DIR="$(eval echo ~"$USER")/.config/suckless"

if [ -d "$SUCKLESS_CONFIG_DIR/dwm" ]; then
    echo "  - Building dwm..."
    (cd "$SUCKLESS_CONFIG_DIR/dwm" && sudo make clean install)
    echo "✅ dwm installed."
else
    echo "› DWM source not found, skipping build."
fi

if [ -d "$SUCKLESS_CONFIG_DIR/slock" ]; then
    echo "  - Building slock..."
    (cd "$SUCKLESS_CONFIG_DIR/slock" && sudo make clean install)
    echo "✅ slock installed."
else
    echo "› slock source not found, skipping build."
fi


# Step 6: Apply distribution-specific tweaks
echo "› Applying distribution-specific tweaks..."
if [[ "$OS_ID" == "fedora" ]]; then
    echo "  - Applying Fedora-specific bash configuration..."
    if [ -f "$HOME/.bashrc_fedora" ]; then
        ln -sf "$HOME/.bashrc_fedora" "$HOME/.bashrc"
        echo "    Linked .bashrc_fedora to .bashrc"
    fi
    if [ -f "$HOME/.bash_profile_fedora" ]; then
        ln -sf "$HOME/.bash_profile_fedora" "$HOME/.bash_profile"
        echo "    Linked .bash_profile_fedora to .bash_profile"
    fi
else
    echo "› No specific tweaks for this OS."
fi


# --- Finalization ---
echo ""
echo "🎉 All done! Your system is configured."
echo "Recommendations:"
echo "  - Please REBOOT or log out and log back in for all changes to take effect."
echo "  - For Neovim, you may need to open it and run :checkhealth or let the plugin manager install plugins."