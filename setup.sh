#!/bin/bash

# ==============================================================================
# My Dotfiles Setup Script
#
# This script automates the setup of my configuration files and tools.
# It performs the following actions:
#   1. Detects the Linux distribution (Fedora, Debian, Arch).
#   2. Installs all necessary dependencies, including build tools and Xorg.
#   3. Uses GNU Stow to symlink configuration files into the correct locations.
#      - Links user configs to the $HOME and /usr directory.
#   4. Compiles and installs dwm and slock from the source in the repo.
#   5. Applies distribution-specific tweaks (e.g., for Fedora's bash files).
#
# Usage:
#   ./setup.sh
#
# ==============================================================================

# --- Configuration & Global Variables ---

# --- Color Definitions ---
# Regular Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables for package installation
INSTALL_CMD=""
ADDITIONAL_PACKAGES=""
CORE_TOOLS_PACKAGES=""
XORG_SERVER_PACKAGES=""
BUILD_TOOLS_PACKAGES=""
FONT_INSTALL_TOOLS_PACKAGES=""
WAYLAND_CONFIG=""


# --- Helper Functions ---

# Function to check if a command exists.
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user to continue or exit on failure
prompt_on_failure() {
    local error_message="$1"
    echo -e "${RED}⛔ ERROR: ${error_message}${NC}"
    echo -e "${YELLOW}Do you want to continue with the setup despite this error? (Y/n)${NC}"
    read -r response
    case "$response" in
        [nN])
            echo -e "${RED}Exiting setup due to error.${NC}"
            exit 1
            ;;
        *)
            echo -e "${YELLOW}Continuing with setup...${NC}"
            return 0
            ;;
    esac
}


# Function to install packages using the globally defined INSTALL_CMD
install_packages() {
    local packages_to_install=("$@")
    echo "       Installing: ${packages_to_install[*]}"

    local failure_count=0
    for pkg in "${packages_to_install[@]}"; do
        echo -e "${CYAN}       Attempting to install: ${pkg}${NC}"
        local current_install_cmd="$INSTALL_CMD $pkg"
        if eval "$current_install_cmd"; then
            echo -e "${GREEN}       ✅ Successfully installed: ${pkg}${NC}"
        else
            echo -e "${RED}       ❌ Failed to install: ${pkg}${NC}"
            failure_count=$((failure_count + 1))
            prompt_on_failure "Package installation failed for: ${pkg}"
        fi
    done

    if [ "$failure_count" -gt 0 ]; then
        echo -e "${YELLOW}Warning: Completed package installation with ${failure_count} failures.${NC}"
        return 1
    else
        echo -e "${GREEN}✅ All packages in this group installed successfully.${NC}"
        return 0
    fi
}

# --- Setup Steps Functions ---

detect_and_set_packages() {
    echo -e "${CYAN}> Detecting package manager and setting package lists...${NC}"

    ADDITIONAL_PACKAGES="alacritty kitty neovim picom waybar wofi feh xbindkeys fastfetch tree tldr bash-completion firefox nemo vlc htop chromium libreoffice qbittorrent bc awk"
    CORE_TOOLS_PACKAGES="git stow"
    FONT_INSTALL_TOOLS_PACKAGES="wget unzip"

    if command_exists dnf; then
        echo ">> DNF detected."
        echo -e "${CYAN}> Updating DNF repositories and upgrading all packages...${NC}"
        sudo dnf update -y
        sudo dnf upgrade -y
        echo -e "${GREEN}✅ DNF repositories updated and packages upgraded.${NC}"
        INSTALL_CMD="sudo dnf install -y"
        BUILD_TOOLS_PACKAGES='@development-tools libX11-devel libXft-devel libXinerama-devel libXrandr-devel'
        XORG_SERVER_PACKAGES="xorg-x11-server-Xorg xorg-x11-xinit xautolock xsetroot bc @cinnamon-desktop"
        WAYLAND_CONFIG="hyprland waybar"
        ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES ShellCheck"
    elif command_exists apt-get; then
      echo ">> APT detected (Hyprland not available)."
        echo -e "${CYAN}› Updating APT repositories and upgrading all packages...${NC}"
        sudo apt-get update
        sudo apt-get upgrade -y
        echo -e "${GREEN}✅ APT repositories updated and packages upgraded.${NC}"
        INSTALL_CMD="sudo apt-get install -y"
        BUILD_TOOLS_PACKAGES="build-essential libx11-dev libxft-dev libxinerama-dev libxrandr-dev"
        XORG_SERVER_PACKAGES="xserver-xorg xinit xautolock xsetroot bc cinnamon"
        ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES shellcheck"
    elif command_exists pacman; then
        echo ">> Pacman detected."
        echo -e "${CYAN}› Updating Pacman repositories and upgrading all packages...${NC}"
        sudo pacman -Syu --noconfirm
        echo -e "${GREEN}✅ Pacman repositories updated and packages upgraded.${NC}"
        INSTALL_CMD="sudo pacman -S --noconfirm --needed"
        CORE_TOOLS_PACKAGES="$CORE_TOOLS_PACKAGES base-devel"
        BUILD_TOOLS_PACKAGES="libx11 libxft libxinerama"
        XORG_SERVER_PACKAGES="xorg-server xorg-xinit xorg-xsetroot bc cinnamon"
        WAYLAND_CONFIG="hyprland hyprpaper waybar"
        ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES shellcheck"
    else
        echo -e "${RED}⛔ ERROR: Could not find a known package manager (dnf, apt-get, pacman).${NC}"
        echo -e "${YELLOW}Please install dependencies manually and re-run this script.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Package manager configured and lists set.${NC}"
}


install_all_dependencies() {
    echo -e "${CYAN}> Installing all required dependencies...${NC}"

    if [ -n "$CORE_TOOLS_PACKAGES" ]; then
        echo "  - installing core tools (git, stow)..."
        install_packages $CORE_TOOLS_PACKAGES
    fi
    
    if [ -n "$XORG_SERVER_PACKAGES" ]; then
        echo "  - Installing X.Org server..."
        install_packages $XORG_SERVER_PACKAGES
    fi

    if command_exists pacman; then
        if ! command_exists yay; then
            echo "yay is NOT installed."
            echo -e "${CYAN}  - Installing yay.${NC}"
            git clone https://aur.archlinux.org/yay-bin.git
            cd yay-bin
            makepkg -si --noconfirm
            cd ..
            rm -rf yay-bin
            echo -e "${CYAN}  - Installing xautolock from AUR.${NC}"
            yay -S --noconfirm --answeredit None --answerdiff None --removemake xautolock
        else
            echo "yay IS installed."
        fi
    fi

    if [ -n "$WAYLAND_CONFIG" ]; then
        echo "  - Installing Wayland setup..."
        install_packages $WAYLAND_CONFIG
    fi

    if [ -n "$BUILD_TOOLS_PACKAGES" ]; then
        echo "  - Installing build tools for dwm/slock..."
        install_packages $BUILD_TOOLS_PACKAGES
    fi

    if [ -n "$ADDITIONAL_PACKAGES" ]; then
        echo "  - installing additional packages (tree, tldr etc)..."
        install_packages $ADDITIONAL_PACKAGES
    fi

    echo -e "${GREEN}✅ Dependencies installed.${NC}"
}

install_nerd_font() {
    echo -e "${CYAN}> Installing Ubuntu Mono Nerd Font...${NC}"

    FONT_NAME_CHECK="UbuntuMono Nerd Font"
    FONT_DIR="$HOME/.local/share/fonts/UbuntuMonoNerdFont"

    echo -e "${CYAN}> Checking if ${FONT_NAME_CHECK} is already installed...${NC}"
    if fc-list | grep -qi "$FONT_NAME_CHECK"; then
        echo -e "${GREEN}✅ ${FONT_NAME_CHECK} is already installed.${NC}"
        echo -e "${YELLOW}If you wish to reinstall, please remove the directory ${FONT_DIR} and try again.${NC}"
        return 0
    else
        echo -e "${YELLOW}Font not found, proceeding with installation.${NC}"
    fi

    echo -e "${CYAN}> Checking for required tools (wget, unzip)...${NC}"
    install_packages $FONT_INSTALL_TOOLS_PACKAGES
    echo -e "${GREEN}✅ Required tools are present.${NC}"

    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip"
    FONT_ZIP="UbuntuMono.zip"

    echo -e "${CYAN}> Creating font directory: ${FONT_DIR}${NC}"
    mkdir -p "$FONT_DIR"

    echo -e "${CYAN}> Downloading Ubuntu Mono Nerd Font...${NC}"
    if wget -O "/tmp/$FONT_ZIP" "$FONT_URL"; then
        echo -e "${GREEN}✅ Font downloaded successfully.${NC}"
    else
        echo -e "${RED}⛔ ERROR: Failed to download font from ${FONT_URL}. Exiting.${NC}"
        return 1
    fi

    echo -e "${CYAN}> Unzipping font into ${FONT_DIR}...${NC}"
    if unzip -o "/tmp/$FONT_ZIP" -d "$FONT_DIR"; then
        echo -e "${GREEN}✅ Font unzipped successfully.${NC}"
    else
        echo -e "${RED}⛔ ERROR: Failed to unzip font to ${FONT_DIR}. Exiting.${NC}"
        return 1
    fi

    echo -e "${CYAN}> Updating font cache...${NC}"
    if fc-cache -fv; then
        echo -e "${GREEN}✅ Font cache updated.${NC}"
    else
        echo -e "${YELLOW}Warning: Failed to update font cache. You may need to run 'fc-cache -fv' manually.${NC}"
    fi

    echo -e "${CYAN}> Cleaning up temporary files...${NC}"
    rm -f "/tmp/$FONT_ZIP"
    echo -e "${GREEN}✅ Cleanup complete.${NC}"

    echo -e "${YELLOW}🎉 Ubuntu Mono Nerd Font installed successfully!${NC}"
    echo -e "${CYAN}Recommendations:${NC}"
    echo "  - You may need to restart your terminal emulator (e.g., Alacritty, Kitty) or applications (e.g., Neovim) to see the new font."
    echo "  - Configure your terminal/application to use 'UbuntuMono Nerd Font' (or 'UbuntuMono Nerd Font Mono')."
    echo -e "${NC}"
}

stow_user_configs() {
    echo -e "${CYAN}> Symlinking user configurations to $HOME...${NC}"
    HOME_PACKAGES=""
    for dir in */; do
        pkg_name="${dir%/}"
        if [[ "$pkg_name" == "etc" || "$pkg_name" == "usr" ]]; then # Skip 'etc' and 'usr' as they require a different target dir
            continue
        fi
        HOME_PACKAGES+="$pkg_name "
    done

    stow --adopt -R -t "$HOME" $HOME_PACKAGES
    echo -e "${GREEN}✅ User dotfiles linked successfully.${NC}"
}

stow_system_configs() {
    echo -e "${CYAN}> Symlinking system-wide configurations to /usr...${NC}"
    if [ -d "etc" ]; then
        sudo stow --adopt -R -t / etc
        echo -e "${GREEN}✅ System-wide configs linked successfully.${NC}"
    else
        echo "> No 'etc' package found, skipping user-wide configs."
    fi

    echo -e "${CYAN}> Symlinking user-wide configurations to /usr...${NC}"
    if [ -d "usr" ]; then
        sudo stow --adopt -R -t / usr
        echo -e "${GREEN}✅ User-wide configs linked successfully.${NC}"
    else
        echo "> No 'usr' package found, skipping user-wide configs."
    fi

}

compile_suckless_tools() {
    echo -e "${CYAN}> Compiling and installing Suckless tools...${NC}"

    local SUCKLESS_BASE_DIR="$HOME/.config"

    local suckless_apps=(
        "dwm"
        "st"
        "dmenu"
        "slock"
    )

    for app in "${suckless_apps[@]}"; do
        local app_dir="$SUCKLESS_BASE_DIR/$app"

        echo "  - Building $app from $app_dir..."

        (
            cd "$app_dir" || { echo -e "${RED}❌ Failed to change directory to $app_dir for $app.${NC}"; exit 1; }
            sudo make clean install || { echo -e "${RED}❌ Failed to compile and install $app.${NC}"; exit 1; }
            echo -e "${GREEN}✅ $app installed.${NC}"
        ) || {
            echo -e "${RED}--- Compilation for $app failed. See above errors. ---${NC}"
        }
    done

    echo -e "${CYAN}> Suckless tools compilation process finished.${NC}"
}

# Evaluate usefullness...
# apply_distribution_specific_tweaks() {
#     echo -e "${CYAN}> Applying distribution-specific tweaks...${NC}"
#     if [[ "$OS_ID" == "fedora" ]]; then
#         echo "  - Applying Fedora-specific bash configuration..."
#         # Assuming you have bash_profile_fedora and bashrc_fedora inside your dotfiles structure,
#         # Stow handles these. If you intended a specific symlink override, uncomment and adjust.
#         # if [ -f "$HOME/.bashrc_fedora" ]; then
#         #     ln -sf "$HOME/.bashrc_fedora" "$HOME/.bashrc"
#         #     echo "    Linked .bashrc_fedora to .bashrc"
#         # fi
#         # if [ -f "$HOME/.bash_profile_fedora" ]; then
#         #     ln -sf "$HOME/.bash_profile_fedora" "$HOME/.bash_profile"
#         #     echo "    Linked .bash_profile_fedora to .bash_profile"
#         # fi
#         echo "> No specific tweaks needed for bash files if handled by stow."
#     else
#         echo "> No specific tweaks for this OS required."
#     fi
#     echo -e "${GREEN}✅ Distribution tweaks applied.${NC}"
# }

finalize_setup() {
    echo -e "${CYAN}> Finalizing setup...${NC}"
    # Effectively overwrites the stowed files that already existed in the OS
    git restore .

    # Enable login via TTY
    sudo systemctl set-default multi-user.target

    echo -e "${YELLOW}🎉 All done! Your system is configured.${NC}"
    echo -e "${CYAN}Recommendations:${NC}"
    echo "  - Please REBOOT or log out and log back in for all changes to take effect."
    echo "  - For Neovim, you may need to open it and run :checkhealth or let the plugin manager install plugins."
    echo "  - Populate $WALLPAPER_DIR directory with your wallpapers!"
    echo -e "${NC}"
}

# --- Main Logic Flow ---
echo -e "${BLUE}🚀 Starting dotfiles setup...${NC}"

detect_and_set_packages
install_all_dependencies
install_nerd_font
stow_user_configs
stow_system_configs
compile_suckless_tools
finalize_setup

echo -e "${GREEN}✨ Setup script finished successfully!${NC}"

# Source the .bash_profile to apply changes immediatly to the current shell and run start_menu
if [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
    echo "    Sourced ~/.bash_profile for immediate effect."
fi

