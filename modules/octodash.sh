#!/usr/bin/env bash
#
# Script d'installation d'octodash
#

if [ -f _common.sh ]; then
  source ./_common.sh
elif [ -d modules ]; then
  source ./modules/_common.sh
fi
sudo echo "" > /dev/null
_log "=> OctoDash"


##################
### PRE-REQUIS ###
##################
_log "  => Pré-requis"
sudo apt install -q -y gir1.2-gnomekeyring-1.0 libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libuuid1 libappindicator3-1 libsecret-1-0 xserver-xorg ratpoison x11-xserver-utils xinit libgtk-3-0 bc desktop-file-utils libavahi-compat-libdnssd1 libpam0g-dev libx11-dev

##################
### PAQUET DEB ###
##################
arch=$(uname -m)
if [[ $arch == x86_64 ]]; then
    releaseURL=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
elif [[ $arch == aarch64 ]]; then
    releaseURL=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*arm64.deb" | cut -d '"' -f 4)
elif  [[ $arch == arm* ]]; then
    releaseURL=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*armv7l.deb" | cut -d '"' -f 4)
fi

# Download deb
_log "  => Téléchargement"
wget -O /tmp/octodash.deb $releaseURL -q --show-progress

# Installation du deb
_log "  => Installation"
sudo dpkg -i /tmp/octodash.deb
rm /tmp/octodash.deb

#####################
### CONFIGURATION ###
#####################
# API
_log "  => Configuration"
_log "    => API"
mkdir -p $(dirname ${CONF_DASH})
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.json ${CONF_DASH}
_config api.allowCrossOrigin true
API_KEY=$(yq3 r ${CONF_OCTO} api.key)
if [ "$API_KEY" != "" ]; then
  sed -i "s/API_KEY/${API_KEY}/g" ${CONF_DASH}
fi

_log "    => Theme"
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.css ${CSS_DASH}
cp -f ${CSS_DASH} ${SHARE_DIR}/octodash-theme.txt

# Config de l'autostart
_log "    => Autostart"
cat <<EOF > ~/.xinitrc
#!/bin/sh

xset s off
xset s noblank
xset -dpms

# Rotation de l'écran
#DISPLAY=:0 xrandr --output HDMI-1 --rotate inverted

ratpoison&
LANG=fr_FR.UTF-8 octodash
#octodash
EOF

# Bash
cat <<EOF >> ~/.bashrc
if [ -z "\$SSH_CLIENT" ] || [ -z "\$SSH_TTY" ]; then
    xinit -- -nocursor
fi
EOF

# ZSH
if [ -f ~/.zshrc ]; then
cat <<EOF >> ~/.zshrc
if [ -z "\$SSH_CLIENT" ] || [ -z "\$SSH_TTY" ]; then
    xinit -- -nocursor
fi
EOF
fi

# Autologin
_log "    => Autologin"
sudo systemctl set-default multi-user.target
sudo ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
sudo bash -c 'cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf' << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
sudo chmod +x ~/.xinitrc
sudo chmod ug+s /usr/lib/xorg/Xorg

# Update
_log "    => Auto-update"
mkdir -p ~/scripts
cat <<EOF > ~/scripts/update-octodash
#!/bin/bash

if [ -f /tmp/octodash.deb ]; then
    dpkg -i /tmp/octodash.deb
    rm /tmp/octodash.deb
fi
EOF
sudo chmod +x ~/scripts/update-octodash
sudo bash -c 'cat >> /etc/sudoers.d/update-octodash' <<EOF
pi ALL=NOPASSWD: /home/pi/scripts/update-octodash
EOF

# Plugins
_plugins "Plugins" "https://github.com/jneilliii/OctoPrint-OctoDashCompanion/archive/master.zip"

# Restart service
sudo systemctl daemon-reload
sudo service getty@tty1 restart