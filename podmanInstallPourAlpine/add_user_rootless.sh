#!/bin/sh

# 06 mars 2025
# v 0.1
#
# But : Configurer un utilisateur pour utiliser Podman en mode rootless


# Vérifier que le script est exécuté avec doas
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté avec les privilèges avec doas (équivalent sudo) et PAS DEPUIS ROOT !" >&2
    exit 1
fi

# Vérifier l'installation de Podman
if ! command -v podman &> /dev/null; then
    echo "Erreur: Podman n'est pas installé. Veuillez installer Podman avant de continuer." >&2
    exit 1
fi

# Vérifier le fonctionnement de base de Podman
if ! podman info &> /dev/null; then
    echo "Erreur: Podman ne fonctionne pas correctement. Veuillez vérifier l'installation et la configuration." >&2
    exit 1
fi

# Vérifier si un nom d'utilisateur est passé en argument
if [ -n "$1" ]; then
    USERNAME="$1"
else
    # Demander le nom d'utilisateur
    read -p "Entrez le nom d'utilisateur pour la configuration rootless: " USERNAME
fi

# Vérifier si l'utilisateur existe
if ! id "$USERNAME" &>/dev/null; then
    echo "Erreur: L'utilisateur $USERNAME n'existe pas !" >&2
    exit 1
fi

# Configurer subuid/subgid ssi l'username n'est pas deja present ...
if ! grep -q "^${USERNAME}:" /etc/subuid; then
    echo "${USERNAME}:100000:65536" >> /etc/subuid
    echo "${USERNAME}:100000:65536" >> /etc/subgid
fi

# Activer le module tun
modprobe tun 2>/dev/null || true
if ! grep -q '^tun' /etc/modules; then
    echo "tun" >> /etc/modules
fi

# Activer le module fuse
modprobe fuse 2>/dev/null || true
if ! grep -q '^fuse' /etc/modules; then
    echo "fuse" >> /etc/modules
fi

# Tester Podman pour l'utilisateur donné
echo "Test de Podman avec hello-world..."
su - "$USERNAME" -c "podman run --rm hello-world"

echo "Configuration de l'utilisateur $USERNAME pour Podman terminée -> OK!"
