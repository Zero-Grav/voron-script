#!/usr/bin/env bash
#
# Installation de ADXL

if [ -f _common.sh ]; then
  source ./_common.sh
elif [ -d modules ]; then
  source ./modules/_common.sh
fi

_log "=> ADXL : Compilation"
sudo echo "" > /dev/null
~/klippy-env/bin/pip install -v numpy
sudo apt install -y --no-install-recommends python-numpy python-matplotlib
