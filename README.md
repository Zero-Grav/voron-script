LISEZ-MOI
=========


## Wifi

Copier le fichier `conf/octopi-wpa-supplicant.sample` en `octopi-wpa-supplicant.txt` avant de lancer le script  ou à placer dans la partition `/boot` de la carte microSD.


## Installation de base (à partir d'une SD vierge):

`./build-script/octoprint-image.sh`

## Arborescence :

* `/home/pi/voron` : Les scripts de ce dépôt
* `{DEPOT}/conf/octopi-wpa-supplicant.txt` : Fichier Wifi a appliquer lors de la création d'une image octoprint
* `/home/pi/klipper` : Source de klipper
* `/home/pi/.octoprint/uploads/system` : Dossier partager
  * `klipper.bin` : Le firmware compilé à flasher
  * `klipper-makeconfig.txt` : Le fichier de configuration de compilation
  * `octodash-theme.txt` : Le theme CSS de dashboard