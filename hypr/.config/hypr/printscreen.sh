#!/bin/sh

grim -g "$(slurp)" - | tee "$HOME/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png" | wl-copy

