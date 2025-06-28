#!/bin/bash

# ==============================================================================
# Clone and Stow Dotfiles
#
# A script to clone a dotfiles repository and use GNU Stow to symlink the
# configuration files into the user's home directory.
# It will detect the OS and auto-install missing dependencies (git, stow).
#
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# IMPORTANT: Change these variables to match your setup.

# The URL of your dotfiles repository on GitHub.
# Example: "https://github.com/your-username/dotfiles.git"
REPO_URL="https://github.com/your-username/dotfiles.git"

# The local directory where the repository will be cloned.
DEST_DIR="$HOME/dotfiles"

# A space-separated list of the packages (directories) to stow.
# These directories should exist in the root of your dotfiles repository.
# Example: "bash git nvim hyprland"
STOW_PACKAGES="bash git nvim"


# --- Helper Functions ---

# Function to check if a command exists.
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install a package using the globally defined INSTALL_CMD
install_package() {
    local package_name="$1"
    echo "›› Installing '$package_name'..."
    # Use eval to correctly execute the command string with arguments
    eval "$INSTALL_CMD \"$package_name\""
}


# --- Main Logic ---

echo "🚀 Starting dotfiles setup..."

# 1. Detect OS and set the appropriate install command.
echo "› Detecting package manager..."
INSTALL_CMD=""
if command_exists dnf; then
    echo "›› Fedora (dnf) detected."
    INSTALL_CMD="sudo dnf install -y"
elif command_exists apt-get; then
    echo "›› Debian/Ubuntu (apt-get) detected. Updating package list..."
    sudo apt-get update
    INSTALL_CMD="sudo apt-get install -y"
elif command_exists pacman; then
    echo "›› Arch (pacman) detected."
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "ERROR: Could not find a known package manager (dnf, apt-get, pacman)."
    echo "Please install dependencies manually and re-run this script."
    exit 1
fi
echo "✅ Package manager configured."


# 2. Check for dependencies (git and stow) and install if missing.
echo "› Checking for dependencies..."
if ! command_exists git; then
    echo "›› Git not found."
    install_package "git"
fi

if ! command_exists stow; then
    echo "›› GNU Stow not found."
    install_package "stow"
fi
echo "✅ Dependencies are satisfied."

# 3. Clone the repository
if [ -d "$DEST_DIR" ]; then
    echo "⚠️  Destination directory $DEST_DIR already exists. Skipping clone."
    echo "    You can run 'git pull' inside it to update."
else
    echo "› Cloning dotfiles repository from $REPO_URL to $DEST_DIR..."
    git clone "$REPO_URL" "$DEST_DIR"
    echo "✅ Repository cloned successfully."
fi

# 4. Use Stow to create symlinks
echo "› Stowing packages: $STOW_PACKAGES"
cd "$DEST_DIR"

# The 'stow' command symlinks files from the current directory to the parent directory ($HOME).
# The -t flag specifies the target directory, which is $HOME.
stow -t "$HOME" $STOW_PACKAGES

echo "✅ Symlinks created successfully."
echo ""
echo "🎉 All done! Your dotfiles are set up."
echo "Please restart your shell or run 'source ~/.bashrc' for changes to take effect."

