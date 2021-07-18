#!/usr/bin/env bash
#
# Script d'installation de la voron sur un octoprint vierge
#


################
### INCLUDES ###
################
source ./modules/_common.sh



#########################
### CHECK UTILISATEUR ###
#########################
if [ `whoami` == 'root' ]; then
  _log "${RED}Ne lancez pas ce script en super-admin"
  exit
elif [ `whoami` != 'pi' ]; then
  _log "${RED}Lancez ce script avec l'utilisateur par défaut : pi"
  exit
else
  # Demande du mdp
  echo -ne "${CYAN}Votre mot de passe est necessaire pour l'installation : ${NC}"
  read -s PI_PASSWORD
  echo -e "${PI_PASSWORD}" | sudo -S ls /tmp > /dev/null
  if [ $? -ne 0 ]; then
    echo "Mauvais MDP"
    exit
  fi

  # Changement du mdp
  if [ "${PI_PASSWORD}" == "${PI_PASSWORD_DEFAULT}" ]; then
    until [ "${PI_PASSWORD}" != "${PI_PASSWORD_DEFAULT}" ]; do
      echo -ne "\n${RED}C'est le bon moment pour changer le mot de passe par défaut !\n${NC}Mot de passe : "
      read -s PI_PASSWORD
    done
    echo -e "${NC}"
    echo -e "${PI_PASSWORD}\n${PI_PASSWORD}" | sudo passwd pi > /dev/null
    echo -e "${PI_PASSWORD}\n${PI_PASSWORD}" | sudo passwd > /dev/null
    echo -e "${CYAN}Changement du mot de passe par défaut : OK${NC}"
  fi
fi
echo -e "\n${RED}/!\ NE VOUS CONNECTEZ PAS SUR OCTOPRINT AVANT LA FIN DE L'INSTALLATION !${NC}"

# Demande hostname
read -p "Hostname [${HOSTNAME_DEFAULT}] : " HOSTNAME
if [ "${HOSTNAME}" = "" ]; then
  HOSTNAME=${HOSTNAME_DEFAULT}
fi



#####################
### INTERNATIONAL ###
#####################
./modules/french.sh

# Hostname
echo -ne "${CYAN}=> Change du nom du systeme : ${RED}"
echo "${HOSTNAME}" | sudo tee /etc/hostname
echo -e "${NC}"
sudo sed -i "s/octopi/${HOSTNAME} octopi/" /etc/hosts



###############
### UPGRADE ###
###############
_log "=> Upgrade"
_log "  => Suppression logiciels inutiles"
sudo apt remove --purge -y -q bluez-firmware bluez libraspberrypi-doc
_log "  => Dépôt"
sudo apt update -q
_log "  => Système"
sudo apt full-upgrade -y



######################
### INSTALL OUTILS ###
######################
_log "=> Outils"

# Oh My ZSH
./modules/ozsh.sh

# YQ
_log "  => Yaml parser"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION} -O /tmp/yq
sudo mv /tmp/yq /usr/local/bin/yq3
chmod +x /usr/local/bin/yq3

# Divers
_log "  => Divers"
sudo apt install -y tree



#########################
### Configuration API ###
#########################
_log "=> Configuration de l'API"
API_KEY=$(head -c16 </dev/urandom|xxd -p -u)
echo -e "${CYAN}  => Génération d'une clé : ${RED}${API_KEY}${NC}"
_config api.enabled true "Activation"
_config api.allowCrossOrigin true
_config api.key ${API_KEY}
_config accessControl.salt $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
_config server.secretKey $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

_log "=> Redémarrage octoprint"
sudo service octoprint restart
sleep 5



###############
### Klipper ###
###############
_log "=> Klipper"
if [ -e ${KLIPPER_DIR} ]; then
  rm -rf ${KLIPPER_DIR}
fi
if [ -e ${KLIPPER_DIR}-env ]; then
  rm -rf ${KLIPPER_DIR}-env
fi
_log "  => Récupération des sources"
git clone https://github.com/KevinOConnor/klipper ${KLIPPER_DIR}
cd ${KLIPPER_DIR}

_log "  => Installation"
./scripts/install-octopi.sh

_log "  => Compilation firmware"
#  make menuconfig
cp ${SCRIPT_DIR}/conf/klipper-makeconfig ${KLIPPER_DIR}/.config
make
mkdir -p ${SHARE_DIR}
cp ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}

_log "  => Configuration"
cp -f ~/voron/conf/${KLIPPER_CONF_VERSION}-klipper.cfg ~/printer.cfg
cd ${SCRIPT_DIR}


####################
### UTILISATEURS ###
####################
_log "=> Ajout d'un utilisateur ${USERNAME}"
${CMD_OCTO} user add --password "${USERNAME}" --admin ${USERNAME} > /dev/null


################
### OCTODASH ###
################
./modules/octodash.sh


###############################
### CONFIGURATION OCTOPRINT ###
###############################
#/oprint/bin/octoprint config effective
_log "=> Configuration octoprint"
_config appearance.name ${HOSTNAME}
_config feature.sdSupport false "Désactivation de la carte SD"
_config plugins.tracking.enabled true "Tracking"
_config server.firstRun false "Désactivation de l'assistance"
_config server.pluginBlacklist.enabled true "Blacklist"
_config appearance.components.disabled.usersettings[0] plugin_appkeys
_config appearance.components.disabled.navbar[0] login

_log "  => Online check"
_config server.onlineCheck.enabled true
_config server.onlineCheck.host "185.121.177.177"

_log "  => Connexion automatique de l'imprimante"
_config serial.autoconnect true
_config serial.baudrate 250000
_config serial.port /tmp/printer

_log "=> Désactivation des plugins inutiles"
_config plugins._disabled[0] errortracking "ErrorTracking"
_config plugins._disabled[1] virtual_printer "VirtualPrinter"
_config plugins._disabled[2] cura "Cura"

_log "  => Temperatures"
_config temperature.cutoff 15
_config temperature.profiles[0].bed 60
_config temperature.profiles[0].extruder 200
_config temperature.profiles[0].name PLA
_config temperature.profiles[1].bed 60
_config temperature.profiles[1].extruder 220
_config temperature.profiles[1].name PETG
_config temperature.profiles[2].bed 90
_config temperature.profiles[2].extruder 230
_config temperature.profiles[2].name ABS


###############
### PLUGINS ###
###############
_log "=> Installation des plugins :"
# FloatingNavbar : Barre de navigation fixe
_plugins "FloatingNavbar" "https://github.com/jneilliii/OctoPrint-FloatingNavbar/archive/master.zip"

# TempsGraph : Graph de temp avancé
_plugins "TempsGraph" "https://github.com/1r0b1n0/OctoPrint-Tempsgraph/archive/master.zip"
_config plugins.tempsgraph.showBackgroundImage false
_config plugins.tempsgraph.startWithAutoScale true

# Webcam
_plugins "WebcamTab" "https://github.com/gruvin/OctoPrint-WebcamTab/archive/master.zip"
_plugins "Webcam FullScreen" "https://github.com/BillyBlaze/OctoPrint-FullScreen/archive/master.zip"

# Klipper
_plugins "Klipper" "https://github.com/AliceGrey/OctoprintKlipperPlugin/archive/master.zip"
_config plugins.klipper.configuration.reload_command FIRMWARE_RESTART
_config plugins.klipper.configuration.connection.replace_connection_panel false
