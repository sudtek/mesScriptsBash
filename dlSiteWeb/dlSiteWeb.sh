#!/bin/bash

# 09/janvier/2025
# yannick SUDRIE
#
# Ce script parcourt un site web spécifié par une URL, télécharge la structure de répertoire et les fichiers.
# Il accepte trois arguments :
# 1. L'URL du site web à parcourir.
# 2. Le nombre de niveaux de répertoires à ignorer dans l'URL.
# 3. Option du nom de répertoire où télécharger les fichiers.
# 4. Option --log pour un suivi du téléchargement.
#
# Le script utilise `wget` pour télécharger les fichiers et `curl` pour obtenir les tailles des fichiers.
# Les fichiers téléchargés sont enregistrés dans un répertoire temporaire,
# qui est conservé à la fin du script pour garantir que la structure et les fichiers téléchargés sont conservés.
#
# Exemple d'utilisation :
# ./dliteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 6 --log
#
# Si les arguments ne sont pas fournis ou sont incorrects, le script affiche un message d'utilisation
# et se termine avec un code d'erreur.

# Vérifier que 2 ou 4 arguments sont passés au script
if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <URL> <nombre de niveaux de répertoires distants à ignorer> <Répertoire_Cible> [--log]"
    exit 1
fi

# Vérifier que les deux premiers arguments ne sont pas vides
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <URL> <nombre de niveaux de répertoires distants à ignorer> <Répertoire_Cible> [--log]"
    exit 1
fi

URL=$1
CUT_DIRS=$2
REPERTOIRE_CIBLE=""
REPERTOIRE_COURANT=$(pwd)
LOG_FILE=""

# Extraire le FQDN de l'URL
FQDN=$(echo $URL | cut -d/ -f3)
#echo "DEBUG : Le nom de domaine est : $FQDN"

# Vérifier si l'utilisateur a fourni un nom de répertoire pour sauvegarder le site web
if [ -n "$3" ] && [ "$3" != "--log" ]; then
    REPERTOIRE_CIBLE=$3
    mkdir -p "$REPERTOIRE_CIBLE" # Créer le répertoire cible
    cd "$REPERTOIRE_CIBLE" # Aller dans le répertoire cible
fi

# Vérifier si l'option --log est passée
if [ "$4" == "--log" ] || [ "$3" == "--log" ]; then
    LOG_FILE=$(date +"%H_%M_%S_%d_%m_%Y_$FQDN.log")
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

# Fonction pour obtenir la taille d'un fichier
get_file_size() {
    local file_url=$1
    local size=$(curl -sI $file_url | grep -i Content-Length | awk '{print $2}')
    echo $size
}

# Fonction pour convertir la taille en une forme lisible par un humain
human_readable_size() {
    local size=$1
    local unit="octets"

    if [ $size -ge 1073741824 ]; then
        size=$((size / 1024 / 1024 / 1024))
        unit="Go"
    elif [ $size -ge 1048576 ]; then
        size=$((size / 1024 / 1024))
        unit="Mo"
    fi

    echo "$size $unit"
}

# Fonction pour extraire le nom du fichier en cours de traitement
get_file_name() {
    local file_url=$1
    local file_name=$(basename "$file_url")
    echo "$file_name"
}

# Fonction pour parcourir les fichiers et obtenir leurs tailles
process_files() {
    local base_url=$1
    echo "Processing URL: $base_url"

    # Utiliser wget pour télécharger les fichiers
    wget --recursive --no-parent --directory-prefix="$REPERTOIRE_CIBLE" --cut-dirs=$CUT_DIRS --reject "index.html*" $base_url 2>&1

    #echo "DEBUG : $REPERTOIRE_CIBLE !!!"
    # Exemple pour l'URL https://softwareupdate.vmware.com stockera les fichiers et l'arborescence en local sur : ../softwareupdate.vmware.com/

}

# Fonction pour calculer les tailles des fichiers téléchargés en local
calculate_local_file_sizes() {
    local total_size=0
    local total_nbFichier=0
    while IFS= read -r line; do
        if [ -f "$line" ]; then
            local file_size=$(stat -c%s "$line")
            local file_name=$(basename "$line")
            local human_readable_size_str=$(human_readable_size $file_size)
            echo "File : $file_name"
            echo "Size : $human_readable_size_str"
            total_size=$((total_size + file_size))
            echo "Updated total size: $(human_readable_size $total_size)"
            total_nbFichier=$((total_nbFichier + 1))
        fi
    done <<< "$(find "$REPERTOIRE_CIBLE" -type f)"

    echo "Taille totale : $(human_readable_size $total_size)"
    echo "Nb total de fichier : $total_nbFichier"
}

# Appeler la fonction pour traiter les fichiers
process_files $URL

# Appeler la fonction pour calculer les tailles des fichiers téléchargés en local
echo "---------------------------------------------------"
calculate_local_file_sizes

# Conserver le répertoire temporaire pour garder la structure et les fichiers téléchargés
echo "Les fichiers téléchargés et la structure des répertoires sont conservés dans le répertoire : $REPERTOIRE_COURANT/$REPERTOIRE_CIBLE"
