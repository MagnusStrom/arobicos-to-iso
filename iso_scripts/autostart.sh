#!/bin/sh

# Autostart electron-app
/home/tc/electron-iso-linux-ia32/electron-iso --no-sandbox --use-gl=swiftshader &


FILE="~/.config/openbox/rc.xml"
echo "*** File - $FILE contents ***"
cat $FILE
