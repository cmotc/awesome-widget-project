#! /bin/sh
# Configure your paths and filenames
SOURCEBINPATH=.
SOURCEDIR=conky/
SOURCEBIN=awmconky
SOURCEHUD=conky/hud.lua
SOURCEDOC=README.md
DEBFOLDER=awesome-conky-hud

DEBVERSION=$(date +%Y%m%d)

if [ -n "$BASH_VERSION" ]; then
	TOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	TOME=$( cd "$( dirname "$0" )" && pwd )
fi
cd $TOME

git pull origin master

DEBFOLDERNAME="$TOME/../$DEBFOLDER-$DEBVERSION"
DEBPACKAGENAME=$DEBFOLDER\_$DEBVERSION

rm -rf $DEBFOLDERNAME
# Create your scripts source dir
mkdir $DEBFOLDERNAME

# Copy your script to the source dir
cp -R $TOME $DEBFOLDERNAME/
cd $DEBFOLDERNAME

pwd

# Create the packaging skeleton (debian/*)
dh_make --indep --createorig 

mkdir -p debian/tmp/usr
cp -R usr debian/tmp/usr

# Remove make calls
grep -v makefile debian/rules > debian/rules.new 
mv debian/rules.new debian/rules 

# debian/install must contain the list of scripts to install 
# as well as the target directory
echo usr/bin/$SOURCEBIN usr/bin > debian/install 
echo etc/conkyrc etc/conkyrc >> debian/install 
echo etc/xdg/awesome/rc.lua.hud.example etc/xdg/awesome >> debian/install
echo etc/xdg/awesome/$SOURCEHUD etc/xdg/awesome/$SOURCEDIR >> debian/install
echo etc/xdg/awesome/debian/menu.lua etc/xdg/awesome/debian/ >> debian/install
echo usr/share/doc/$DEBFOLDER/$SOURCEDOC usr/share/doc/$DEBFOLDER >> debian/install

echo "Source: $DEBFOLDER
Section: unknown
Priority: optional
Maintainer: cmotc <cmotc@openmailbox.org>
Build-Depends: debhelper (>= 9)
Standards-Version: 3.9.5
Homepage: https://www.github.com/awesome-conky-hud
#Vcs-Git: git@github.com:cmotc/awesome-conky-hud
#Vcs-Browser: https://www.github.com/cmotc/awesome-conky-hud

Package: $DEBFOLDER
Architecture: all
Depends: lightdm, lightdm-gtk-greeter, awesome (>= 3.4), conky, awesome-conky-starter, \${misc:Depends}
Description: A modified version of the debian rc.lua which starts conky, and
 a script which makes sure awesomewm only starts it once.
" > debian/control

#echo "gsettings set org.gnome.desktop.session session-name awesome-gnome
#dconf write /org/gnome/settings-daemon/plugins/cursor/active false
#gconftool-2 --type bool --set /apps/gnome_settings_daemon/plugins/background/active false
#" > debian/postinst
# Remove the example files
rm debian/*.ex
rm debian/*.EX

# Build the package.
# You  will get a lot of warnings and ../somescripts_0.1-1_i386.deb
debuild -us -uc >> ../log
