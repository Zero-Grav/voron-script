#!/usr/bin/env bash
#
# Mise à jour de klipper
# /!\ Lancé en user pi sans sudo

if [ -f _common.sh ]; then
  source ./_common.sh
elif [ -d modules ]; then
  source ./modules/_common.sh
fi

cd ${KLIPPER_DIR}
git pull
./scripts/install-octopi.sh

#  make menuconfig
make clean
if [ -e ${SHARE_DIR}/klipper-makeconfig.txt ]; then
  cp -f ${SHARE_DIR}/klipper-makeconfig.txt ${KLIPPER_DIR}/.config
elif [ -e ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ]; then
  cp -f ${SCRIPT_DIR}/conf/klipper/makeconfig.txt ${KLIPPER_DIR}/.config
fi

if [ ${DEVMODE} -eq 0 ]; then
  make
  cp -f ${KLIPPER_DIR}/out/klipper.bin ${SHARE_DIR}
else
  rm ${SHARE_DIR}/klipper-empty.bin
  touch ${SHARE_DIR}/klipper-empty.bin
fi

exit 0