#!/bin/sh

# 08_mars_2025
#
# yannick Sudrie
# V_0.1
#
# But : Corriger l'erreur "WARN[0000] "/" is not a shared mount" dans Alpine Linux avec Podman
# Source : https://wiki.alpinelinux.org/wiki/Podman

#       Testé sur:
#       Alpine Linux v3.21
#       podman version 5.3.2
#       OS/Arch: linux/amd64

# Informations pour l'utilisateur
echo "-------------------------------------------------------------------"
echo "Ce script nécessite 'doas' pour les privilèges élevés. "
echo "Ce script corrige l'erreur suivante dans Alpine Linux avec Podman :"
echo "WARN[0000] \"/\" is not a shared mount, this could cause issues or missing mounts with rootless containers"
echo ""
echo "Cette erreur se produit car le montage de la partition racine (/) n'a pas l'option 'shared',"
echo "ce qui est nécessaire pour le bon fonctionnement des conteneurs rootless avec Podman."
echo ""
echo "Le script va :"
echo "1. Installer 'findmnt' si nécessaire (utilitaire pour vérifier les montages)."
echo "2. Modifier le fichier /etc/fstab pour ajouter l'option 'shared' au montage de la partition racine."
echo "3. Vous demander de redémarrer pour appliquer les changements."
echo "-------------------------------------------------------------------"
echo ""

# Vérification des privilèges (doas)
if ! command -v doas &> /dev/null; then
  echo "Erreur : 'doas' n'est pas installé. Ce script nécessite 'doas' pour les privilèges élevés."
  exit 1
fi

# Vérifier que le script est exécuté avec doas
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté avec les privilèges avec doas (équivalent sudo) et PAS DEPUIS ROOT !" >&2
    exit 1
fi

# Vérification du système (Alpine Linux)
if ! grep -q "Alpine" /etc/os-release; then
  echo "Ce script est conçu pour Alpine Linux. Votre système ne semble pas être Alpine."
  exit 1
fi

# Installation de findmnt si nécessaire
if ! command -v findmnt &> /dev/null; then
  echo "Le paquet 'findmnt' n'est pas installé. Installation en cours..."
  doas apk add util-linux
  if ! command -v findmnt &> /dev/null; then
    echo "Échec de l'installation de 'findmnt'. Le script ne peut pas continuer."
    exit 1
  fi
  echo "'findmnt' a été installé avec succès."
else
  echo "'findmnt' est déjà installé."
fi

# Sauvegarde du fichier /etc/fstab
doas cp /etc/fstab /etc/fstab.bak

# Débogage : Afficher la ligne correspondante
echo "Ligne trouvée dans /etc/fstab :"
doas grep -E "^UUID=[0-9a-fA-F-]+\s+\/\s+ext4\s+rw,relatime\s+0\s+1" /etc/fstab

# Modification de /etc/fstab
if doas grep -qE "^UUID=[0-9a-fA-F-]+\s+\/\s+ext4\s+rw,relatime\s+0\s+1" /etc/fstab; then
  doas sed -i -E '/^UUID=[0-9a-fA-F-]+\s+\/\s+ext4\s+rw,relatime\s+0\s+1/ s/(rw,relatime)/&,shared/' /etc/fstab
  echo -e "Le fichier /etc/fstab a été modifié pour inclure l'option 'shared'."
else
  echo "Erreur : Aucune entrée correspondant à 'ext4' avec les options attendues pour la partition racine '/' n'a été trouvée dans /etc/fstab."
  echo "Veuillez vérifier manuellement votre fichier /etc/fstab."
  exit 1
fi

# Instructions pour l'utilisateur
echo ""
echo "-------------------------------------------------------------------"
echo "Pour appliquer les changements, redémarrez votre système :"
echo "doas reboot"
echo ""
echo "Après le redémarrage, vérifiez que le montage est bien en mode 'shared' :"
echo "doas findmnt -o PROPAGATION /"
echo "Le résultat doit afficher 'shared' sous la colonne PROPAGATION."
echo "-------------------------------------------------------------------"
