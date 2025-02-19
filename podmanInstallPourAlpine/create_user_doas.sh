#!/bin/sh

# 18 fevrier 2025
# yannick SUDRIE
# But : Permet à cet user de faire un doas (équivalent à sudo chez alpine)
# en ROOT ou via un utilisateur avec pouvoir doas executer ce script
# Prerequis : avoir créé le user  il faut avoir prvia la commande useradd 


# Vérifie si le script est exécuté en tant que superutilisateur
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que superutilisateur ( root ou un utilisateur qui a le droit de faire doas )."
   exit 1
fi

# Met à jour la liste des paquets
apk update

# Demande le nom d'utilisateur
read -p "Entrez le nom de l'utilisateur à créer: " USERNAME

# Vérifie si doas est déjà installé
if ! command -v doas &> /dev/null; then
    # Installe doas
    apk add doas
else
    echo "Le package doas est déjà installé !"
fi

# Crée l'utilisateur et l'ajoute au groupe wheel
adduser $USERNAME wheel

# Autorise les utilisateurs du groupe wheel à utiliser doas
echo "permit persist :wheel" > /etc/doas.d/doas.conf

# Affiche un message de succès
echo "L'utilisateur $USERNAME a été créé et configuré pour utiliser doas."

echo " ATTENTION veuillez vous déconnecter et vous reconnecter avec le nouveau compte !!"
