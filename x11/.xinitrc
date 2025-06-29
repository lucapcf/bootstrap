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
    
    #xrandr --output DP-1 --auto --primary
    #xrandr --output eDP-1 --auto --left-of HDMI-1

    # Setting wallpaper
     ~/scripts/fehbg_slideshow &

    # Lockscreen
    ~/xssstate/xsidle.sh slock &
     xset s 900

    # Starting DWM status
    ~/dwm/scripts/status.sh &

    # Start DWM
    exec dwm
    ;;
  cinnamon)
    exec cinnamon-session
    ;;
  *)
    ;;
esac

