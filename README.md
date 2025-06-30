# My Dotfiles

This repository contains my personal configuration files (dotfiles) for a streamlined and customized Linux environment. The `setup.sh` script automates the installation of necessary dependencies, symlinks the configurations, and sets up key tools.

## ✨ Features

* **[span_0](start_span)Multi-Distribution Support**: Automatically detects and adapts installations for Fedora, Debian/Ubuntu-based systems, and Arch Linux[span_0](end_span).
* **[span_1](start_span)Automated Dependency Installation**: Installs core tools (git, stow), X.Org server, build essentials, and a suite of desktop applications (Alacritty, Kitty, Neovim, Picom, tmux, Waybar, Wofi, Feh, xbindkeys, fastfetch)[span_1](end_span).
* **[span_2](start_span)Hybrid Desktop Environment/Window Manager Setup**: Supports the installation of Hyprland (Wayland) and Cinnamon (X11), along with compiling `dwm` and `slock` from source[span_2](end_span).
* **[span_3](start_span)GNU Stow Integration**: Uses GNU Stow to intelligently symlink configuration files from this repository to their correct locations in your home directory (`$HOME`) and system-wide (`/etc`)[span_3](end_span).
* **[span_4](start_span)Nerd Font Installation**: Automatically downloads and installs Ubuntu Mono Nerd Font for enhanced terminal aesthetics and icon support[span_4](end_span).
* **[span_5](start_span)Modular Bash Configuration**: Organizes `~/.bashrc` into a `~/.bashrc.d` directory for cleaner management of aliases, functions, and environment variables[span_5](end_span).
* **[span_6](start_span)Interactive Session Selector**: A `start_session` script (referenced in `bash_profile.txt`) allows interactive selection between different desktop environments/window managers (Hyprland, dwm, Cinnamon) upon console login[span_6](end_span).

## 🚀 Getting Started

### Prerequisites

* A fresh installation of Fedora, Debian/Ubuntu-based, or Arch Linux.
* [span_7](start_span)`git` should be installed (the setup script will attempt to install it if missing)[span_7](end_span).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/your-dotfiles-repo.git](https://github.com/your-username/your-dotfiles-repo.git) ~/.dotfiles
    ```
    (Replace `https://github.com/your-username/your-dotfiles-repo.git` with the actual URL of your dotfiles repository).

2.  **Navigate into the dotfiles directory:**
    ```bash
    cd ~/.dotfiles
    ```

3.  **Run the setup script:**
    ```bash
    ./setup.sh
    ```
    The script will:
    * [span_8](start_span)Detect your operating system and package manager[span_8](end_span).
    * [span_9](start_span)Prompt for `sudo` password when necessary for package installations and system-wide symlinks[span_9](end_span).
    * [span_10](start_span)Install all required software[span_10](end_span).
    * [span_11](start_span)Symlink your dotfiles into place[span_11](end_span).
    * [span_12](start_span)Compile and install `dwm` and `slock` (if their source directories exist in your dotfiles)[span_12](end_span).
    * [span_13](start_span)Install Ubuntu Mono Nerd Font[span_13](end_span).

## 📁 Repository Structure

The repository is organized to work seamlessly with GNU Stow:

