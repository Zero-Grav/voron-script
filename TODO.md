TODO
====

* [ ] Installation initiale :
    * [ ] Configuration de base d'octoprint :
        * [ ] Orders :
            * [ ] navbar
            * [ ] sidebar
            * [ ] tab
            * [ ] settings
    * [ ] Configuration des options de boot RPI :
        * [ ] Sondes
        * [x] SPI pour neoled
    * [ ] Octodash :
        * [ ] Configuration des boutons d'actions
        * [ ] Veille
        * [X] Rotation de l'écran
        * [ ] Splashscreen
    * [ ] Plugins :
        * [ ] À configuration :
            * [X] BackupScheduler
            * [ ] Enclosure :
                * [ ] DS18B20 :
                    * [x] Ajouter les sondes
                    * [ ] Adresses
                * [ ] SSR Imprimante
                * [ ] Extracteur
                * [ ] NeoLed
            * [ ] WideScreen
            * [ ] TabOrder
            * [X] UploadAnything (à confirmer)
            * [ ] Dashboard
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
            * [ ] DragonOrder
            * [ ] PrettyGCode
            * [ ] TerminalCommands
            * [ ] Webhooks
            * [ ] OctoRelay
            * [X] Octolapse
            * [ ] PrintJobHistory
            * [ ] Printer Statistics
            * [ ] Stateful Sidebar
            * [ ] System Command Editor
            * [ ] TemperatureFailsafe
            * [ ] Top Temp
            * [ ] ws281x
            * [ ] UI Customizer / Themeify 
    * [ ] Divers :
        * [ ] GPIO serveur :
            * [X] Installation
            * [ ] Configuration des pins
            * [ ] Script pour le démarrage/arrêt de nodejs
            * [ ] Forever en mode dev
        * [x] Crontab :
            * [x] boot
            * [X] interval régulier
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
    * [ ] Klipper :
        * [x] Upgrade du git
        * [ ] Système d'overwrite de la conf
        * [x] Compilation du bin
        * [x] Copie du bin dans un dossier de DL
    * [ ] Dev :
        * [ ] Script de backup
        * [ ] Script pour optimiser le fichier img
        * [X] Versionner sur git
        * [ ] Compléter la doc
* [ ] Divers :
    * [ ] InfluxDB ou API rest
    * [ ] MQTT
    * [ ] VPN ?