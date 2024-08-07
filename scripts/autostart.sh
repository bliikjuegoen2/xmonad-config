#!/bin/bash

myWallpaper="/home/bliikjuegoen/Pictures/space.jpg";
SCRIPTS=$HOME/.xmonad/scripts

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}


#Set your native resolution IF it does not exist in xrandr
#More info in the script
#run $HOME/.xmonad/scripts/set-screen-resolution-in-virtualbox.sh

#Find out your monitor name with xrandr or arandr (save and you get this line)
#xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal
#xrandr --output DP2 --primary --mode 1920x1080 --rate 60.00 --output LVDS1 --off &
#xrandr --output LVDS1 --mode 1366x768 --output DP3 --mode 1920x1080 --right-of LVDS1
#xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off

# (sleep 2; run $HOME/.config/polybar/launch.sh) &

#change your keyboard if you need it
#setxkbmap -layout be

#cursor active at boot
xsetroot -cursor_name left_ptr &

# start panel - ideally should be at start so that system is usable right away
xfce4-panel &

#start ArcoLinux Welcome App
# run dex $HOME/.config/autostart/arcolinux-welcome-app.desktop

#Some ways to set your wallpaper besides variety or nitrogen
feh --bg-fill $myWallpaper &
# feh --bg-fill $myWallpaper &
#start the conky to learn the shortcuts
# (conky -c $HOME/.xmonad/scripts/system-overview) &

# enable reverse scrolling
xinput set-prop 'SYNA7DAB:00 06CB:CD40 Touchpad' 'libinput Natural Scrolling Enabled' 1 &

# enable mouse while typing
xinput set-prop "SYNA7DAB:00 06CB:CD40 Touchpad" "libinput Disable While Typing Enabled" 0 &


# disable numlock key
$SCRIPTS/disable-numlock.fish

# enable autolocking
xautolock -time 5 -locker "betterlockscreen -l dim" -notify 10 -notifier "yad --info --text='locking in 10 seconds'" -bell -restart &

# enable redshift
/usr/lib/geoclue-2.0/demos/agent &

# start redshift
$SCRIPTS/start-redshift.fish &

#starting utility applications at boot time
# run variety &
run nm-applet &
run pamac-tray &
run xfce4-power-manager &
run volumeicon &
blueberry-tray &
picom --experimental-backends -b --config $SCRIPTS/picom.conf &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/xfce4/notifyd/xfce4-notifyd &


#starting user applications at boot time
#nitrogen --restore &
#run caffeine &
#run vivaldi-stable &
#run firefox &
#run thunar &
#run spotify &
#run atom &

#run telegram-desktop &
#run discord &
#run dropbox &
#run insync start &
#run ckb-next -b &
