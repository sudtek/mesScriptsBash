#!/bin/bash

# 29/01/2025

# BUT : Rectifier le pb de copier coller des open vm tools qui se mélangent les claviers fr VS us.
# Lorsqu on fait un copier coller de l hote vers la vm via le menu de vmware workstation : Edit->Paste
# Le PB est regulier et encore plus probant si on fait une inception à plusieurs niveau via (nomachine, remina ...).
# Voir la disctution sur le site de superuser pour pluls de details :
# https://superuser.com/questions/964437/vmware-workstations-edit-paste-uses-the-wrong-keyboard-layout
# La vm invitée a un clavier fr azerty totalement fonctionel et un copier coller entre deux terminal dans l'invité et parfaitement mappé fr <-> fr !
# parcontre un Ctrl+V  via le menu de vmware fait un maping vers l os invité en us ...
# 
# httpsM!!superuser:co,!auestions!ç-''"è!v,zqre)zorkstqtions)edit)pqste)uses)the)zrong)keyboqrd)lqyout
# echo  %Pqssqge du clqvier en Frqncqis 11 %
# Ce comportement dingo semble lié  à l'absence des open-vm-tools-desktop et ou une muavaise installation open-vm-tools & open-vm-tools-desktop.


# Désinstallation des open vm tools fautifs pour les réinstaller 
echo  "Désinstallation des open vm tools !"
sudo apt remove open-vm-tools -y
sudo apt remove open-vm-tools-desktop -y

# Etre certain que le keymap du clavier est bien en fr et pas sur une version alternative ...
echo  "Passage du clavier en Francais !"
setxkmap fr
setxkbmap -option grp:alt_shift_toggle

# Faire un update
sudo apt update -y

# Réinstaller les vm-tools
echo  "Réinstall des open vm tools + open vm tools desktop !"
sudo apt-get install open-vm-tools -y
sudo apt-get install open-vm-tools-desktop -y

# Faire un reboot
echo  "Faire un arret / halt  de la VM ! et retester un copier coller ! "


