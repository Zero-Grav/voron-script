#!/usr/bin/env bash
#
# Synchro du dossier share
# /!\ Lancer via cron en user pi sans sudo

if [ -f _common.sh ]; then
  source ./_common.sh
elif [ -d modules ]; then
  source ./modules/_common.sh
fi

# Copier un fichier (fichier1, fichier2)
# Si le fichier 1 est + récent que le 2 : écrasement
_synchroFile() {
    if [ "$1" -nt "$2" ];then
        cp -f "$1" "$2"
    else
        cp -f "$2" "$1"
    fi
}

# Synchro des fichiers de base
mkdir -p ${SHARE_DIR}
_synchroFile ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}/klipper.bin
_synchroFile ${SHARE_DIR}/klipper-makeconfig.txt ${KLIPPER_DIR}/.config
_synchroFile ${SHARE_DIR}/octodash-theme.txt ${CSS_DASH}
