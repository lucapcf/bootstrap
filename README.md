# My Dotfiles

This repository contains my personal configuration files (dotfiles) for a streamlined and customized Linux environment. The `setup.sh` script automates the installation of necessary dependencies, symlinks the configurations, and sets up key tools.

## ✨ Features

* **Multi-Distribution Support**: Automatically detects and adapts installations for Fedora, Debian/Ubuntu-based systems, and Arch Linux.
* **Automated Dependency Installation**: Installs core tools (git, stow), X.Org server, build essentials, and a suite of desktop applications (Alacritty, Kitty, Neovim, Picom, tmux, Waybar, Wofi, Feh, xbindkeys, fastfetch).
* **Hybrid Desktop Environment/Window Manager Setup**: Supports the installation of Hyprland (Wayland) and Cinnamon (X11), along with compiling `dwm` and `slock` from source.
* **GNU Stow Integration**: Uses GNU Stow to intelligently symlink configuration files from this repository to their correct locations in your home directory (`$HOME`) and system-wide (`/etc`).
* **Nerd Font Installation**: Automatically downloads and installs Ubuntu Mono Nerd Font for enhanced terminal aesthetics and icon support.
* **Modular Bash Configuration**: Organizes `~/.bashrc` into a `~/.bashrc.d` directory for cleaner management of aliases, functions, and environment variables.
* **Interactive Session Selector**: A `start_session` script (referenced in `bash_profile.txt`) allows interactive selection between different desktop environments/window managers (Hyprland, dwm, Cinnamon) upon console login.

## 🚀 Getting Started

### Prerequisites

* A fresh installation of Fedora, Debian/Ubuntu-based, or Arch Linux.
* `git` should be installed (the setup script will attempt to install it if missing).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/lucapcf/workstation_setup.git](https://github.com/lucapcf/workstation_setup.git) ~/.dotfiles
    ```
    (Replace `https://github.com/your-username/your-dotfiles-repo.git` with the actual URL of your dotfiles repository).

2.  **Navigate into the dotfiles directory:**
    ```bash
    cd ~/workstation_setup
    ```

3.  **Run the setup script:**
    ```bash
    ./setup.sh
    ```
    The script will:
    * Detect your operating system and package manager.
    * Prompt for `sudo` password when necessary for package installations and system-wide symlinks.
    * Install all required software.
    * Symlink your dotfiles into place.
    * Compile and install `dwm` and `slock` (if their source directories exist in your dotfiles).
    * Install Ubuntu Mono Nerd Font.

## 📁 Repository Structure

* `setup.sh` - The main setup script
* `README.md` - This file
* `.bashrc` - The main bash config, sources `~/.bashrc.d/*`
* `.bash_profile` - Login shell config, sources `~/.bashrc`
* `connfig.txt` - (Example content, typically individual files in `.bashrc.d/`)
* `alacritty/` - Alacritty config
* `bashrc.d/` - Directory for modular bash configurations
    * `aliases.sh` - Contains shell aliases
    * `completion.sh` - Enables command auto-completion
    * `environment.sh` - Sets various environment variables
    * `fastfetch.sh` - Runs fastfetch on shell startup
    * `keybindings.sh` - Defines custom keybindings (e.g., vi mode Ctrl-l)
    * `ls_colors.sh` - Defines colors for `ls` command
    * `prompt.sh` - Custom shell prompt with Git branch info
* `nvim/` - Neovim configuration
* `picom/` - Picom (compositor) configuration
* `tmux/` - Tmux configuration
* `waybar/` - Waybar config (for Hyprland)
* `wofi/` - Wofi config (Wayland launcher)
* `Xresources` - X resources for X11 applications
* `scripts/` - Custom scripts (e.g., `start_session`)
    * `start_session` - Script to select WM/DE on TTY1 login
* `etc/` - Directory for system-wide configs symlinked to `/etc`
    * `X11/`
        * `xinit/`
            * `xinitrc` - X server startup script
            * ... and other system-wide configurations


## 🛠️ Post-Installation

1.  **Reboot or Log Out:** For all changes to take effect, especially environment variables and font installations, it is highly recommended to **reboot your system or log out and log back in**.
2.  **Terminal Font:** Configure your terminal emulator (e.g., Alacritty, Kitty) to use "UbuntuMono Nerd Font" or "UbuntuMono Nerd Font Mono".
3.  **Neovim Plugins:** Open Neovim and run `:checkhealth` or allow your plugin manager to install plugins.

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. If you have suggestions for improvements or find issues, please open an issue or submit a pull request.
