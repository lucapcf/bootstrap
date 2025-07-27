# .bashrc

case $- in
    *i*) ;;
    *) return;;
esac

# Get system info
command -v fastfetch &>/dev/null && fastfetch

# Source system bashrc
if [ -f /etc/bash.bashrc ]; then
    . "/etc/bash.bashrc"
elif [ -f /etc/bashrc ]; then
    . "/etc/bashrc"
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases, envs and functions
if [ -d ~/.config/.bashrc.d ]; then
    for rc in ~/.config/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
