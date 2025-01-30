#!/bin/bash

# 29/01/2025

# BUT : Rectifier le problème de copier-coller des Open VM Tools qui mélangent les claviers FR et US.
# Lorsqu'on fait un copier-coller de l'hôte vers la VM via le menu de VMware Workstation : Edit -> Paste
# Le problème est régulier et encore plus probant si on fait une inception à plusieurs niveaux via (NoMachine, Remmina...).
# Voir la discussion sur le site de SuperUser pour plus de détails :
# https://superuser.com/questions/964437/vmware-workstations-edit-paste-uses-the-wrong-keyboard-layout
# La VM invitée a un clavier FR AZERTY totalement fonctionnel et un copier-coller entre deux terminaux dans l'invité est parfaitement mappé FR <-> FR !
# Par contre, un Ctrl+V via le menu de VMware fait un mapping vers l'OS invité en US...
# https://superuser.com/questions/964437/vmware-workstations-edit-paste-uses-the-wrong-keyboard-layout
# echo "Passage du clavier en Français 11%"
# Ce comportement étrange semble lié à l'absence des open-vm-tools-desktop et/ou une mauvaise installation de open-vm-tools & open-vm-tools-desktop.

# Désinstallation des open vm tools fautifs pour les réinstaller 
echo  "Désinstallation des open vm tools !"
sudo apt remove open-vm-tools -y
sudo apt remove open-vm-tools-desktop -y

# Etre certain que le keymap du clavier est bien en fr et pas sur une version alternative ...
echo  "Passage du clavier en Francais !"
setxkbmap fr
setxkbmap -option grp:alt_shift_toggle

# Faire un update
sudo apt update -y

# Réinstaller les vm-tools
echo  "Réinstall des open vm tools + open vm tools desktop !"
sudo apt-get install open-vm-tools -y
sudo apt-get install open-vm-tools-desktop -y

# Faire un reboot
echo  "Faire un arret / halt  de la VM ! et retester un copier coller ! "
