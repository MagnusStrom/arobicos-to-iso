# electron-iso-packager
ArobicOS, being web-based, cannot run on it's own. This script, made by lucafabbian(and slightly modified to fit arobicos) Compiles arobicOS into the iso.

Under the hood, this script calls [electron-packager](https://github.com/electron/electron-packager) to obtain a linux32 packaged version of your app and then puts the result inside a remastered version of [Tinycore Linux](https://distro.ibiblio.org/tinycorelinux/), a slim linux distro, with only the bare necessary to run Electron + a window manager ([openbox](http://openbox.org/wiki/Main_Page)) and a minimal terminal.  

Check out the main build for more.
