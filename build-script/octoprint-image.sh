#!/usr/bin/env bash
#
# Créer une image neuve d'octoprint sur la SD

#################
### VARIABLES ###
#################
DEVICE="/dev/sdc"
USER=$(whoami)
MOUNT_DIR=/media/${USER}
IMG="/data/ISO/2020-12-02-octopi-buster-armhf-lite-0.18.0.img"
WIFI_CONF="../conf/octopi-wpa-supplicant.txt"


# Check utilisateur
if [ '${USER}' == 'root' ]; then
  echo "Ne lancez pas ce script en super-admin"
  exit
fi

# Params
if [ "$1" = "-h" ]; then
    echo "Usage : $0 [Image] [Device]"
    exit
fi
if [ -z "$1" ]; then
    read -p "Image [${IMG}] :" IMG_TMP
    if [ ! -z ${IMG_TMP} ]; then
        IMG=${IMG_TMP}
    fi
fi
if [ -z "$2" ]; then
    read -p "Device [${DEVICE}] :" DEVICE_TMP
    if [ ! -z ${DEVICE_TMP} ]; then
        DEVICE=${DEVICE_TMP}
    fi
fi

# Confirmation
echo -e "=> Source : ${CYAN}${IMG}${NC}"
echo -e "=> Destination : ${CYAN}${DEVICE}${NC}"
read -p "Confirmation [Y/n] ?" CONFIRM
if [ "${CONFIRM}" = "n" ] || [ "${CONFIRM}" = "N" ]; then
    echo -e "${RED}Annulation${NC}"
    exit
fi

# Check périphérique
if [ ! -f ${IMG} ]; then
    echo "Image introuvable"
    exit
elif [ ! -e ${DEVICE} ]; then
    echo "Périphérique introuvable"
    exit
fi
echo "=> Préparation du flash de ${IMG} => ${DEVICE}"

# Démontage des devices
echo "  => Démontages des périphériques"
if [ $(ls ${MOUNT_DIR} | wc -l) -ne 0 ]; then
    umount ${MOUNT_DIR}/*
fi

# Lancement du flash de la SD
sudo dd if=${IMG} of=${DEVICE} status=progress
sudo sync

# Copie du fichier Wifi
if [ -f ${WIFI_CONF} ]; then
    echo "  => Copie du fichier de configuration Wifi"
    mkdir ${MOUNT_DIR}/boot
    sudo mount ${DEVICE}1 ${MOUNT_DIR}/boot
    sudo cp -f ${WIFI_CONF} ${MOUNT_DIR}/boot/octopi-wpa-supplicant.txt
    sudo umount ${MOUNT_DIR}/boot
    rmdir ${MOUNT_DIR}/boot
else
    echo "/!\ Pas de fichier de configuration Wifi détecter"
fi

# Sync
echo -ne "  => Synchro du périphérique ${DEVICE}"
sudo sync
echo " : OK"