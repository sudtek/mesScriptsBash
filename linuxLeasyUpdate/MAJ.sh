#!/bin/sh

# linuxLeasyUpdate - Mise à jour simplifiée pour Linux
# Version : V0.1
# Date : 15_avril_2025

# Instructions d'utilisation :
# 1. Téléchargez ou clonez ce script localement.
# 2. Rendez-le exécutable avec la commande : sudo chmod +x MAJ.sh
# 3. Exécutez-le avec : ./MAJ.sh

# Ce script bash simplifie les mises à jour du système Linux (testé sur Raspberry Pi et Ubuntu).

# Mise à jour des listes de paquets
sudo apt-get update -y

# Mise à niveau des paquets installés
sudo apt-get upgrade -y

# Mise à niveau de la distribution (peut supprimer des paquets obsolètes)
sudo apt-get dist-upgrade -y

echo "Mise à jour du système terminée."

