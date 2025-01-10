# 08/janvier/2025
# yannick SUDRIE
#
# Ce script parcourt un site web spécifié par une URL et calcule la taille totale des fichiers
# sans les télécharger ni créer de répertoires locaux. Il accepte deux arguments :
# 1. L'URL du site web à parcourir.
# 2. Le nombre de niveaux de répertoires à ignorer dans l'URL.
#
# Le script utilise `wget` en mode spider pour lister les fichiers et `curl` pour obtenir les tailles des fichiers.
# Les fichiers et répertoires créés par `wget` sont enregistrés dans un répertoire temporaire,
# qui est supprimé à la fin du script pour garantir qu'aucun fichier ou répertoire local n'est créé.
#
# Exemple d'utilisation :
# ./evalTailleSiteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 6
#
# Si les arguments ne sont pas fournis ou sont incorrects, le script affiche un message d'utilisation
# et se termine avec un code d'erreur.

# Vérifier que deux ou trois arguments sont passés au script
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <URL> <nombre de niveaux de répertoires à ignorer> [--log]"
    exit 1
fi

# Vérifier que les arguments ne sont pas vides
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <URL> <nombre de niveaux de répertoires à ignorer> [--log]"
    exit 1
fi

URL=$1
CUT_DIRS=$2
TOTAL_SIZE=0
TEMP_DIR=$(mktemp -d)

# Option pour activer le logging
LOG_FILE=""
if [ "$3" == "--log" ]; then
    LOG_FILE=$(date +"%H_%M_%S_%d_%m_%Y_$(echo $URL | awk -F[/:] '{print $4}').log")
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

    # Utiliser wget en mode spider pour lister les fichiers sans créer de répertoires locaux
    wget_output=$(wget --spider -r -np -nH --cut-dirs=$CUT_DIRS -R "index.html*" -P "$TEMP_DIR" $base_url 2>&1)
    echo "wget output: $wget_output"

    # Extraire les URLs et les tailles des fichiers directement à partir de la sortie de wget
    while IFS= read -r line; do
        if [[ $line =~ (http://|https://.*) ]]; then
            file=${BASH_REMATCH[1]}
            file_name=$(get_file_name "$file")
        elif [[ $line =~ Length:\ ([0-9]+) ]]; then
            size=${BASH_REMATCH[1]}
            human_readable_size_str=$(human_readable_size $size)
            echo "File: $file_name"
            echo "Size: $human_readable_size_str"
            TOTAL_SIZE=$((TOTAL_SIZE + size))
            echo "Updated total size: $(human_readable_size $TOTAL_SIZE)"
        fi
    done <<< "$(echo "$wget_output" | grep -E 'http://|https://|Length:')"
}

# Fonction pour afficher l'animation de chargement
show_loading_animation() {
    local delay=0.1
    local spinner=('|' '/' '-' '\')

    while true; do
        for spin in "${spinner[@]}"; do
            printf "\r[%c] Crawling... " "$spin"
            sleep $delay
        done
    done
}

# Lancer l'animation de chargement en arrière-plan
show_loading_animation &
loading_pid=$!

# Appeler la fonction pour traiter les fichiers
process_files $URL

# Arrêter l'animation de chargement
kill $loading_pid

# Convertir la taille totale en une forme lisible par un humain
TOTAL_SIZE_READABLE=$(human_readable_size $TOTAL_SIZE)

echo "Taille totale : $TOTAL_SIZE_READABLE"

# Supprimer le répertoire temporaire
# Bien que mktemp soit automatiquement purgé à la fin du script,
# il est toujours bon de s'assurer que les ressources temporaires sont correctement nettoyées.
rm -rf "$TEMP_DIR"
