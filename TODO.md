TODO
====

* [ ] Installation initiale :
    * [X] Vérifier l'utilisateur courant
    * [X] Forcer la modification du mdp pi/root
    * [X] Passage du RPI en FR
    * [X] Changer le hostname
    * [X] Virer les paquets inutiles
    * [X] MàJ des dépôts et du Rpi
    * [X] Installation des outils :
        * [X] Oh my ZSH
        * [X] YML parser
    * [ ] Configuration de base d'octoprint :
        * [ ] Orders :
            * [ ] navbar
            * [ ] sidebar
            * [ ] tab
            * [ ] settings
    * [X] Configuration de l'imprimante dans octoprint
    * [ ] Configuration des options de boot RPI
    * [X] Klipper :
        * [X] Téléchargement des sources
        * [X] Installation
        * [X] Compilation
        * [X] Copie des fichiers binaires dans un dossier téléchargeable via octoprint
        * [X] Plugins Octoklipper :
            * [X] Installation
            * [X] Configuration
    * [ ] Octodash :
        * [X] Installation d'octodash
        * [X] Installation du plugins octodash-companion
        * [ ] Configuration :
            * [X] Octodash
            * [ ] Plugins
        * [ ] Veille
        * [ ] Rotation de l'écran
        * [ ] Splashscreen
        * [ ] Custom CSS
    * [ ] Plugins :
        * [ ] Configuration :
            * [ ] OctoDash-Companion
            * [ ] Enclosure
            * [ ] Calibration Companion
            * [ ] Action Commands et/ou GCODE System Commands
            * [ ] Consolidate Temp Control
            * [ ] CooldownNotification
            * [ ] Custom Control Editor
            * [ ] Draggable Files
            * [ ] Exclude Region
            * [ ] Firmware Updater
            * [ ] Filament Manager + CostEstimation
            * [ ] MarlinGcodeDocumentation
            * [ ] Navbar Temp
            * [ ] Dashboard
            * [ ] DragonOrder
            * [ ] PrettyGCode
            * [ ] TerminalCommands
            * [ ] Webhooks
            * [ ] OctoRelay
            * [ ] Octolapse
            * [ ] PrintJobHistory
            * [ ] Printer Statistics
            * [ ] Stateful Sidebar
            * [ ] System Command Editor
            * [ ] TemperatureFailsafe
            * [ ] Top Temp
            * [ ] WLED Connection
            * [ ] UI Customizer / Themeify 
    * [ ] Divers :
        * [ ] GPIO serveur
        * [ ] Crontab :
            * [ ] boot
            * [ ] interval régulier
            * [X] Backup
        * [ ] Log
* [ ] Upgrade :
    * [ ] Script d'upgrade :
        * [ ] MàJ du RPI
        * [ ] Nettoyage des apt
        * [ ] GPIO serveur
        * [ ] YQ
    * [ ] Dossier octoprint :
        * [ ] Vérifier présence de fichier zip
        * [ ] Décompresser dans un temp
        * [ ] Màj des scripts maisons
        * [ ] Scripts pour les différents sauts de version
* [ ] Scripts custom :
    * [ ] Bouton Rpi power :
        * [ ] Allumage de la LED au boot
        * [ ] Simple pression : NADA
        * [ ] Pression 3s :
            * [ ] LED : clignote rapide
            * [ ] Action : Reboot lors du relâchement
        * [ ] Pression 5s :
            * [ ] LED : clignote lent
            * [ ] Action : Arrêt lors du relâchement
        * [ ] Pression 8s :
            * [ ] LED : continue
            * [ ] Action : nada
    * [ ] Beep
    * [ ] ADXL :
        * [ ] Installation
        * [ ] Compilation
        * [ ] Configuration
    * [ ] Klipper :
        * [ ] Upgrade du git
        * [ ] Système d'overwrite de la conf
        * [ ] Compilation du bin
        * [ ] Copie du bin dans un dossier de DL
    * [ ] Dev :
        * [x] Script pour build une image vierge :
            * [X] Passer en param l'img et le device
        * [X] Révocation clé SSH :
            * [X] Passer en param l'adresse IP
        * [ ] Script de backup
        * [ ] Script pour optimiser le fichier img
        * [ ] Versionner sur git
* [ ] Backup :
    * [ ] Crontab
    * [ ] ./oprint/bin/octoprint plugins backup
    * [X] Plugins de backup
* [ ] Divers :
    * [ ] InfluxDB ou API rest
    * [ ] MQTT
    * [ ] VPN gkx ?