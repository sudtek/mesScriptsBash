#!/bin/sh

# Script pour vérifier l'état de Podman (rootless et SELinux)
# Auteur : yannick sudrie
# Date : 13 mars 2025 
# Description : Ce script démontre comment extraire des informations spécifiques de `podman info`
#               en utilisant à la fois les templates Go et `jq` pour contourner les limitations.

# Fonction pour extraire une valeur en utilisant un template Go
get_valeur_template() {
    podman info --format "{{$1}}"
}

# Fonction pour extraire une valeur en utilisant jq
get_valeur_json() {
    podman info --format json | jq -r "$1"
}

# 1. Vérifier si Podman est en mode rootless
# Utilisation d'un template Go (fonctionne car .Host.Security.Rootless est accessible)
PODMAN_ROOTLESS=$(get_valeur_template ".Host.Security.Rootless")
echo "DEBUG - Mode rootless (template Go) : $PODMAN_ROOTLESS"

if [ "$PODMAN_ROOTLESS" == "true" ]; then
    echo "OK -> Podman est en mode rootless."
else
    echo "NOK -> Podman n'est pas en mode rootless."
fi

# 2. Vérifier si SELinux est activé
# Le template Go ne fonctionne pas pour .Host.Security.SelinuxEnabled (champ non accessible)
# Utilisation de jq pour extraire la valeur directement du JSON
SELINUX_ENABLED=$(get_valeur_json ".host.security.selinuxEnabled")
echo "DEBUG - SELinux activé (jq) : $SELINUX_ENABLED"

if [ "$SELINUX_ENABLED" == "true" ]; then
    echo "OK -> SELinux est activé."
else
    echo "NOK -> SELinux n'est pas activé."
fi

# 3. Exemple d'erreur avec un template Go non valide
# Ceci générera une erreur car .Host.Security.SelinuxEnabled n'est pas accessible
echo "Tentative d'utilisation d'un template Go non valide :"
podman info --format '{{.Host.Security.SelinuxEnabled}}' || echo "Erreur : Champ SelinuxEnabled inaccessible via template Go."

# Fin du script
echo "Script terminé."
