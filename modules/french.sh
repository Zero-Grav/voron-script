#!/usr/bin/env bash
#
# Passage du RPI en français
if [ -f _common.sh ]; then
  source ./_common.sh
elif [ -d modules ]; then
  source ./modules/_common.sh
fi

#########################
### CHECK UTILISATEUR ###
#########################
if [ `whoami` == 'root' ]; then
  _log "${RED}Ne lancez pas ce script en super-admin"
  exit
fi
sudo echo "" > /dev/null

#####################
### INTERNATIONAL ###
#####################
_log "=> Passage du RPI en FR"

# Timezone
_log "  => Timezone"
echo "Europe/Paris" | sudo tee /etc/timezone > /dev/null
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Keyboard
_log "  => Clavier"
sudo sed -i 's/^XKBLAYOUT="gb"$/XKBLAYOUT="fr"/' /etc/default/keyboard
sudo sed -i 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
_log "=> Date : $(date)"
