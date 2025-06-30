#!/bin/sh

# Reload Hyprland config
hyprctl reload

# Restart Hyprpaper
pkill hyprpaper
hyprpaper &

# Restart Waybar
pkill waybar
waybar &

