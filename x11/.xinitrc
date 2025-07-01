# Redirect stdout and stderr to a log file
exec > ~/startx.log 2>&1

# Keybinds (common to all WMs)
xbindkeys &

# Default session is kde-wayland if none is provided as an argument
session=${1:-'cinnamon'}

case $session in
  dwm)
    # Starting compositor
    picom -f &
    
    # Set accordingly
    #xrandr --output DP-1 3440x1440 --primary
    #xrandr --output HDMI-1 1920x1080 --left-of DP-1

    # Setting wallpaper
     ~/scripts/fehbg_slideshow &

    # Lockscreen
    xautolock -time 10 -locker "slock" -detectsleep &

    # Starting DWM status
    pkill status.sh
    ~/.config/dwm/scripts/status.sh &

    # Start DWM
    exec dwm
    ;;
  cinnamon)
    exec cinnamon-session
    ;;
  *)
    ;;
esac

