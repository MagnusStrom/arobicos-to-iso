#!/bin/bash

# electron-iso-packager v 1.0.0
# Feel free to edit it!
# Tinycore remaster guide: http://wiki.tinycorelinux.net/wiki:remastering

# Author: luca fabbian <luca.fabbian.1999@gmail.com>
# License: MIT


# Usage message and error check
USAGE="Usage: electron-iso-packager <sourcedir> <appname> [postscript]
    sourcedir      the base directory of the application source
    appname        the name of the app
    ROOT USER REQUIRED!

Examples:
    sudo electron-iso-packager ./ MyApp
    sudo electron-iso-packager ./ MyApp \"read -n 1\" # Wait keypress before packaging iso
"
if test "$#" -lt 2; then
    echo "$USAGE"
    echo -e "\033[0;31mERROR: illegal number of parameters (2 required, $# passed)\033[0m
    "
    exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo "$USAGE"
   echo -e "\033[0;31mERROR: this script must be run as root!\033[0m
    "
   exit 1
fi


# Params parsing
APPDIR=$1        # Electron app dir
APPNAME=$2       # Iso name and label
POSTSCRIPT=$3    # Script called before building


# Retrieve script real path and store current path
DIR=`dirname $(readlink -f $0)`  # Script path
KIOSKDIR="$DIR/extract/home/tc"  # Subdir
ISO_FILE="$DIR/core.iso"         # Iso file
CURRENTDIR=$PWD                  # Current path

echo "Running electron-iso-packager"
echo "1/5    -> Preparing build...
"
# Clear (if something has gone wrong previously)
rm -rf "$APPDIR/electron-iso-linux-ia32"
rm -rf "$APPDIR/$APPNAME.iso"
rm -rf "$DIR/extract"
rm -rf "$DIR/iso_src/"
# Package app thanks to electron-packager
/opt/hostedtoolcache/node/14.17.3/x64/lib/node_modules/electron-packager/bin/electron-packager.js $1 --platform=linux --arch=ia32 electron-iso
cp "$DIR/iso_scripts/autostart.sh" ./electron-iso-linux-ia32
echo "
2/5    -> Executing postscript (if specified)...
"
eval "$POSTSCRIPT"
# Unpackage iso file
# Clear (if something has gone wrong previously)
echo "
3/5    -> Extracting iso files...
"
mkdir /mnt/tmp-electron-iso
mount "$ISO_FILE" /mnt/tmp-electron-iso -o loop,ro

mkdir -p "$DIR/iso_src"
cp -r "/mnt/tmp-electron-iso/boot"  "$DIR/iso_src"
rm -fr "$DIR/iso_src/boot/core.gz"

mkdir -p "$KIOSKDIR"
cd "$DIR/extract"
zcat /mnt/tmp-electron-iso/boot/core.gz | sudo cpio -i -H newc -d
cp ../iso_scripts/xsession ./home/tc/.xsession
umount /mnt/tmp-electron-iso
rm -r /mnt/tmp-electron-iso
cd $CURRENTDIR

# Move packaged app inside iso rootfs and compress
echo "
4/5    -> Compressing files...
"
mv ./electron-iso-linux-ia32 $KIOSKDIR/
chmod 777 -R $KIOSKDIR
cd $DIR/extract
find | cpio -o -H newc | gzip -2 > ../iso_src/boot/core.gz
cd ..
# Create iso file
echo "
5/5    -> Creating iso...
"
mkisofs -l -J -R -V "$APPNAME" -no-emul-boot -boot-load-size 4 \
 -boot-info-table -b boot/isolinux/isolinux.bin \
 -c boot/isolinux/boot.cat -o output.iso iso_src
# Clear again
rm -rf "$APPDIR/electron-iso-linux-ia32"
rm -rf "$DIR/extract"
rm -rf "$DIR/iso_src/"
# Move output to the folder where the script has been called
mv output.iso "$CURRENTDIR/$APPNAME.iso"

echo "
...done! Iso file saved as $CURRENTDIR/$APPNAME.iso"
