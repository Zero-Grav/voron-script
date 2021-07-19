#!/usr/bin/env bash
#
# Configuration commune
#

#################
### VARIABLES ###
#################
# Globale
HOSTNAME_DEFAULT="voron"              # Hostname
HOSTNAME=${HOSTNAME_DEFAULT}          # Hostname
USERNAME=${HOSTNAME_DEFAULT}          # Octoprint user
PI_PASSWORD_DEFAULT="raspberry"       # Mot de passe
PI_PASSWORD=${PI_PASSWORD_DEFAULT}    # Mot de passe

# Versions
YQ_VERSION="3.4.0/yq_linux_arm"         # Version de Yaml parser
KLIPPER_CONF_VERSION="210718"           # Fichier de configuration klipper

# Couleurs
CYAN="\033[1;36m"
NC="\033[0m"
RED="\033[1;31m"

# Dossiers/Fichiers
SCRIPT_DIR="/home/pi/voron"
KLIPPER_DIR="/home/pi/klipper"
SHARE_DIR="/home/pi/.octoprint/uploads/system"
GPIO_DIR="${SCRIPT_DIR}/gpio"
CONF_OCTO="/home/pi/.octoprint/config.yaml"
CONF_DASH="/home/pi/.config/octodash/config.json"
CMD_OCTO="/home/pi/oprint/bin/octoprint"
PIP_BIN="/home/pi/oprint/bin/pip"


#################
### FONCTIONS ###
#################
# Afficher d'un texte (texte à afficher)
_log() {
  echo -e "${CYAN}$1${NC}"
}

# Configuration octoprint.yml (parametre, valeur, [texte log])
_config() {
  if [ ! -z "$3" ]; then
    _log "  => $3"
  fi
  yq3 w -i ${CONF_OCTO} $1 $2
}

# Installation d'un plugin
_plugins() {
    _log "  => $1"
    $PIP_BIN install -q --disable-pip-version-check $2
}