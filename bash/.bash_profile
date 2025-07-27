#!/bin/bash

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# Run session-related startup script if on tty1 and no DISPLAY
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
    ~/scripts/start_menu
fi
