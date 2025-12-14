
# My Dotfiles + Ansible Setup

This repository contains my personal configuration files (dotfiles) for a customized Linux environment. The setup is managed via **Ansible** using the `setup.yml` playbook, which automates installation, configuration, and symlinking of all key tools and settings.

## **⚠️ WARNING: Potential Data Loss and System Instability ⚠️**

**This Ansible playbook makes significant changes to your system, including installing packages, modifying configuration files, and symlinking directories. Running it may:**

* **Overwrite or delete existing files** in your home directory or other system locations.
* **Break existing programs or configurations** due to conflicts or changes in dependencies.
* **Lead to system instability or render your system unbootable** if not used carefully or if unforeseen issues arise.
* **Prevent the repository from being renamed, relocated, or deleted** without breaking the symlinks and losing your configuration changes.

**It is strongly recommended that you:**

* **BACK UP ALL IMPORTANT DATA** before running this playbook.
* **Understand what the playbook does** before executing it. Review `setup.yml` thoroughly.
* **Use this playbook on a fresh installation or a virtual machine** if you are unsure.
* **Proceed at your own risk.** The author is not responsible for any damage or data loss that may occur.

## ✨ Features

* **Multi-Distribution Support**: Automatically detects and adapts installations for Fedora, Debian, and Arch Linux.
* **Automated Dependency Installation**: Installs core tools (git, stow), X.Org server, build essentials, and a suite of desktop applications (Alacritty, Neovim, Waybar, Wofi, xbindkeys, fastfetch etc).
* **Hybrid Desktop Environment/Window Manager Setup**: Supports the installation of Hyprland (Wayland) and Cinnamon (X11), along with compiling `dwm` and `slock` from source.
* **GNU Stow Integration**: Uses GNU Stow to intelligently symlink configuration files from this repository to their correct locations in your home directory (`$HOME`) and system-wide (`/etc`, `/usr`).
* **Nerd Font Installation**: Automatically downloads and installs Ubuntu Mono Nerd Font for enhanced terminal aesthetics and icon support.
* **Modular Bash Configuration**: Organizes bash configuration files into `~/.config/.bashrc.d` for cleaner management of aliases, functions, and environment variables.
* **Interactive Session Selector**: The startup script `start_menu` allows interactive selection between different desktop environments/window managers (Hyprland, dwm, Cinnamon) upon console login.

## 🚀 Getting Started

### Prerequisites

* A fresh installation of Fedora, Debian, or Arch based Linux Distros.
* Sudo privileges
* `git` and `ansible` installed (see below)

### Installation

1.  **Clone the repository:**
        ```bash
        git clone https://github.com/lucapcf/bootstrap.git
        cd bootstrap
        ```

2.  **Install Ansible:**
        - On Fedora:
            ```bash
            sudo dnf install ansible
            ```
        - On Debian/Ubuntu:
            ```bash
            sudo apt update && sudo apt install ansible
            ```
        - On Arch:
            ```bash
            sudo pacman -S ansible
            ```

3.  **Run the Ansible playbook:**
        ```bash
        sudo ansible-playbook setup.yml
        ```
        The playbook will:
        * Detect your operating system and package manager.
        * Prompt for `sudo` password when necessary for package installations and system-wide symlinks.
        * Install all required software.
        * Symlink your dotfiles into place using GNU Stow.
        * Compile and install `dwm`, `st`, `dmenu`, and `slock` (if their source directories exist).
        * Install Ubuntu Mono Nerd Font.

## 🛠️ Post-Installation

1.  **Reboot or Log Out:** For all changes to take effect, especially environment variables and font installations, it is highly recommended to **reboot your system or log out and log back in**.
2.  **Terminal Font:** Configure your terminal emulator (e.g., Alacritty, Kitty) to use "UbuntuMono Nerd Font" or "UbuntuMono Nerd Font Mono".
3.  **Neovim Plugins:** Open Neovim and run `:checkhealth` or allow your plugin manager to install plugins.

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. If you have suggestions for improvements or find issues, please open an issue or submit a pull request.
