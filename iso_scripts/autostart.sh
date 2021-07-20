#!/bin/sh

# Autostart electron-app
/home/tc/electron-iso-linux-ia32/electron-iso --no-sandbox --use-gl=swiftshader &

# Default tinycore desktop .xsession
"$DESKTOP" 2>/tmp/wm_errors &
export WM_PID=$!
hsetroot -add "#000000" -add "#000000" -gradient 0 -center /usr/local/share/pixmaps/logo.png # Change to set custom background
[ -x $HOME/.mouse_config ] && $HOME/.mouse_config &
[ $(which "$ICONS".sh) ] && ${ICONS}.sh &
[ -d "/usr/local/etc/X.d" ] && find "/usr/local/etc/X.d" -type f -o -type l -print | while read F; do . "$F"; done
[ -d "$HOME/.X.d" ] && find "$HOME/.X.d" -type f -print | while read F; do . "$F"; done

FILE="~/.config/openbox/rc.xml"
echo "*** File - $FILE contents ***"
cat $FILE