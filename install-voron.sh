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

# Dev mode
DEVMODE=0
read -p "Development environnement ? [y/N] " ASK_DEV
if [ "${ASK_DEV}" == "y" ]; then
  DEVMODE=1
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
if [ ${DEVMODE} -eq 0 ]; then
  sudo apt full-upgrade -y
fi


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

# Crontab
_log "  => Crontab"
sudo cp ${SCRIPT_DIR}/conf/crontab /etc/cron.d/voron-cron
sudo sed -i "s/[SHARE_DIR]/${SHARE_DIR}/g" /etc/cron.d/voron-cron
sudo sed -i "s/[SCRIPT_DIR]/${SCRIPT_DIR}/g" /etc/cron.d/voron-cron
mkdir -p ${SHARE_DIR}

# NeoLed
echo "core_freq_min=500" | sudo tee -a /boot/config.txt > /dev/null
sudo sed -i "s/#dtparam=spi=on/dtparam=spi=on/" /boot/config.txt

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
cp ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ${KLIPPER_DIR}/.config
cp ${KLIPPER_DIR}/.config ${SHARE_DIR}/klipper-makeconfig.txt
if [ ${DEVMODE} -eq 0 ]; then
  make
  cp -f ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}
else
  touch ${SHARE_DIR}/klipper-empty.bin
fi

_log "  => Configuration"
cp -f ~/voron/conf/${KLIPPER_CONF_VERSION}-klipper.cfg ~/printer.cfg
cp -f ~/voron/conf/klipper-macro.txt ${SHARE_DIR}/klipper-macro.txt
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
_log "=> Rotation de l'écran"
DISPLAY=:0 xrandr --output HDMI-1 --rotate inverted
DISPLAY=:0 xrandr --output HDMI-2 --rotate normal
sudo sed -i "s/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/" /boot/config.txt
sudo sed -i "s/MatchIsTouchscreen \"on\"/MatchIsTouchscreen \"on\"\r\n\tOption \"TransformationMatrix\" \"-1 0 1 0 -1 1 0 0 1\"/g" /usr/share/X11/xorg.conf.d/40-libinput.conf
sed -i "s/#DISPLAY/DISPLAY/g" ~/.xinitrc

###############################
### CONFIGURATION OCTOPRINT ###
###############################
_log "=> Profil d'imprimante"
cp -f ${SCRIPT_DIR}/conf/voron.profile /home/pi/.octoprint/printerProfiles/_default.profile

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
_config plugins._disabled[1] cura "Cura"
if [ ${DEVMODE} -eq 1 ]; then
  _config plugins.tracking.enabled false "Tracking"
  _config plugins.virtual_printer.enabled true
else
  _config plugins._disabled[2] virtual_printer "VirtualPrinter"
fi

_log "=> Temperatures"
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
_config plugins.klipper.connection.replace_connection_panel false

# Enclosure
_plugins "Enclosure" "https://github.com/vitormhenrique/OctoPrint-Enclosure/archive/master.zip"
_log "   => Sonde caisson"
_config plugins.enclosure.rpi_inputs[0].action_type output_control
_config plugins.enclosure.rpi_inputs[0].label Caisson
_config plugins.enclosure.rpi_inputs[0].input_type temperature_sensor
_config plugins.enclosure.rpi_inputs[0].gpio_pin '4'
_config plugins.enclosure.rpi_inputs[0].index_id 1
_config plugins.enclosure.rpi_inputs[0].input_pull_resistor input_pull_up
_config plugins.enclosure.rpi_inputs[0].edge fall
_config plugins.enclosure.rpi_inputs[0].controlled_io null
_config plugins.enclosure.rpi_inputs[0].controlled_io_set_value low
_config plugins.enclosure.rpi_inputs[0].temp_sensor_type 18b20
_config plugins.enclosure.rpi_inputs[0].ds18b20_serial 28-001
_config plugins.enclosure.rpi_inputs[0].filament_sensor_enabled true
_config plugins.enclosure.rpi_inputs[0].use_fahrenheit false
_config plugins.enclosure.rpi_inputs[0].temp_sensor_temp ''
_config plugins.enclosure.rpi_inputs[0].temp_sensor_address ''
_config plugins.enclosure.rpi_inputs[0].temp_sensor_humidity ''
_config plugins.enclosure.rpi_inputs[0].temp_sensor_navbar true
_log "   => Sonde ambiance"
_config plugins.enclosure.rpi_inputs[1].action_type output_control
_config plugins.enclosure.rpi_inputs[1].label Ambiance
_config plugins.enclosure.rpi_inputs[1].input_type temperature_sensor
_config plugins.enclosure.rpi_inputs[1].gpio_pin '4'
_config plugins.enclosure.rpi_inputs[1].index_id 1
_config plugins.enclosure.rpi_inputs[1].input_pull_resistor input_pull_up
_config plugins.enclosure.rpi_inputs[1].edge fall
_config plugins.enclosure.rpi_inputs[1].controlled_io null
_config plugins.enclosure.rpi_inputs[1].controlled_io_set_value low
_config plugins.enclosure.rpi_inputs[1].temp_sensor_type 18b20
_config plugins.enclosure.rpi_inputs[1].ds18b20_serial 28-002
_config plugins.enclosure.rpi_inputs[1].filament_sensor_enabled true
_config plugins.enclosure.rpi_inputs[1].use_fahrenheit false
_config plugins.enclosure.rpi_inputs[1].temp_sensor_temp ''
_config plugins.enclosure.rpi_inputs[1].temp_sensor_address ''
_config plugins.enclosure.rpi_inputs[1].temp_sensor_humidity ''
_config plugins.enclosure.rpi_inputs[1].temp_sensor_navbar true
_log "   => Sonde élec"
_config plugins.enclosure.rpi_inputs[2].action_type output_control
_config plugins.enclosure.rpi_inputs[2].label Élec
_config plugins.enclosure.rpi_inputs[2].input_type temperature_sensor
_config plugins.enclosure.rpi_inputs[2].gpio_pin '4'
_config plugins.enclosure.rpi_inputs[2].index_id 1
_config plugins.enclosure.rpi_inputs[2].input_pull_resistor input_pull_up
_config plugins.enclosure.rpi_inputs[2].edge fall
_config plugins.enclosure.rpi_inputs[2].controlled_io null
_config plugins.enclosure.rpi_inputs[2].controlled_io_set_value low
_config plugins.enclosure.rpi_inputs[2].temp_sensor_type 18b20
_config plugins.enclosure.rpi_inputs[2].ds18b20_serial 28-00
_config plugins.enclosure.rpi_inputs[2].filament_sensor_enabled true
_config plugins.enclosure.rpi_inputs[2].use_fahrenheit false
_config plugins.enclosure.rpi_inputs[2].temp_sensor_temp ''
_config plugins.enclosure.rpi_inputs[2].temp_sensor_address ''
_config plugins.enclosure.rpi_inputs[2].temp_sensor_humidity ''
_config plugins.enclosure.rpi_inputs[2].temp_sensor_navbar true

# DashBoard
_plugins "DashBoard" "https://github.com/j7126/OctoPrint-Dashboard/archive/master.zip"

# Upload Everything
_plugins "UploadEverything" "https://github.com/rlogiacco/UploadAnything/archive/master.zip"
_config plugin.uploadanything.allowed: '3mf, obj, stl, png, gif, jpg, bin, zip, txt, log'

# Octolapse
_plugins "Octolapse" "https://github.com/FormerLurker/Octolapse/archive/master.zip"

# FileManager
_plugins "FileManager" "https://github.com/Salandora/OctoPrint-FileManager/archive/master.zip"

# HeaterTemp
_plugins "HeaterTimeout" "https://github.com/google/OctoPrint-HeaterTimeout/archive/master.zip"
_config plugins.HeaterTimeout.enabled true
_config plugins.HeaterTimeout.timeout 900

# SlicerThumbnails
_plugins "SlicerThumbnails" "https://github.com/jneilliii/OctoPrint-PrusaSlicerThumbnails/archive/master.zip"

# BackupScheduler
_plugins "BackupScheduler" "https://github.com/jneilliii/OctoPrint-BackupScheduler/archive/master.zip"
_config plugins.backupscheduler.daily.enabled true
_config plugins.backupscheduler.daily.exclude_timelapse true
_config plugins.backupscheduler.daily.exclude_uploads true
_config plugins.backupscheduler.daily.retention '7'
_config plugins.backupscheduler.daily.time '01:00'
_config plugins.backupscheduler.weekly.day '7'
_config plugins.backupscheduler.weekly.enabled true
_config plugins.backupscheduler.weekly.exclude_timelapse true
_config plugins.backupscheduler.weekly.exclude_uploads true
_config plugins.backupscheduler.weekly.retention '4'
_config plugins.backupscheduler.weekly.time '02:00'

# Autoscroll
_plugins "Autoscroll" "https://github.com/MoonshineSG/OctoPrint-Autoscroll/archive/master.zip"

# ActiveFiltersExtended
_plugins "ActiveFiltersExtended" "https://github.com/jneilliii/OctoPrint-ActiveFiltersExtended/archive/master.zip"
_config plugins.active_filters_extended.activeFilters[0] '(Send: (N\d+\s+)?M105)|(Recv:\s+(ok\s+([PBN]\d+\s+)*)?([BCLPR]|T\d*):-?\d+)'
_config plugins.active_filters_extended.activeFilters[1] '(Send: (N\d+\s+)?M27)|(Recv: SD printing byte)|(Recv: Not SD printing)'
_config plugins.active_filters_extended.activeFilters[2] 'Recv: wait'
_config plugins.active_filters_extended.activeFilters[3] 'Recv: (echo:\s*)?busy:\s*processing'

# RequestSpinner
_plugins "RequestSpinner" "https://github.com/OctoPrint/OctoPrint-RequestSpinner/archive/master.zip"

# DisplayLayerProgress
_plugins "DisplayLayerProgress" "https://github.com/OllisGit/OctoPrint-DisplayLayerProgress/releases/latest/download/master.zip"
_config plugins.DisplayLayerProgress.showAllPrinterMessages false
_config plugins.DisplayLayerProgress.showOnBrowserTitle false
_config plugins.DisplayLayerProgress.showOnNavBar false
_config plugins.DisplayLayerProgress.showOnPrinterDisplay false

# PrintTimeGenius
_plugins "PrintTimeGenius" "https://github.com/eyal0/OctoPrint-PrintTimeGenius/archive/master.zip"

# WideScreen
_plugins "WideScreen" "https://github.com/jneilliii/OctoPrint-WideScreen/archive/master.zip"
_plugins "TabOrder" "https://github.com/jneilliii/OctoPrint-TabOrder/archive/master.zip"

# preheat
_plugins "preheat" "https://github.com/marian42/octoprint-preheat/archive/master.zip"
_config plugins.preheat.enable_chamber false

############
### ADXL ###
############
if [ ${DEVMODE} -eq 0 ]; then
  ./modules/adxl.sh
else
  _log "=> ADXL (Pas de compilation en environnement de dev)"
fi

####################
### GPIO Serveur ###
####################
_log "=> GPIO Serveur"
sudo apt install -y --no-install-recommends nodejs npm
cd ${GPIO_DIR}
npm install

#############################
### FIN DE L'INSTALLATION ###
#############################
./modules/update-octoprint.sh

_log " => ${RED} Redémarrage service octoprint"
sudo service octoprint restart
sleep 5

_log "Fin de l'installation : Nettoyage"
sudo apt autoremove -y

_log "Backup post-installation"
${CMD_OCTO} plugins backup:backup