TODO
====

* [ ] Installation initiale :
    * [ ] Configuration de base d'octoprint :
        * [ ] Orders :
            * [ ] navbar
            * [ ] sidebar
            * [ ] tab
            * [ ] settings
    * [ ] Configuration des options de boot RPI
    * [ ] Octodash :
        * [ ] Configuration des boutons d'actions
        * [ ] Veille
        * [ ] Rotation de l'écran
        * [ ] Splashscreen
    * [ ] Plugins :
        * [ ] À configuration :
            * [ ] BackupScheduler
            * [ ] ActiveFilter
            * [ ] Enclosure
            * [ ] WideScreen
            * [ ] TabOrder
            * [ ] UploadAnything
        * [ ] À tester/valider :
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
    * [X] ADXL :
        * [X] Installation
        * [X] Compilation
        * [X] Configuration
    * [ ] Klipper :
        * [ ] Upgrade du git
        * [ ] Système d'overwrite de la conf
        * [ ] Compilation du bin
        * [ ] Copie du bin dans un dossier de DL
    * [ ] Dev :
        * [ ] Révocation clé SSH :
            * [X] Passer en param l'adresse IP
            * [ ] Copier la clé directement sur le nouveau Rpi
        * [ ] Script de backup
        * [ ] Script pour optimiser le fichier img
        * [ ] Versionner sur git
        * [ ] Compléter la doc
        * [X] Compilation spécifique lors du dev
* [X] Backup :
    * [X] Crontab
    * [X] ./oprint/bin/octoprint plugins backup
* [ ] Divers :
    * [ ] InfluxDB ou API rest
    * [ ] MQTT
    * [ ] VPN gkx ?