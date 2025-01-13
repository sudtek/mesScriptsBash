#!/bin/bash

# 13/janvier/2025 
# V_0.1
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
#
# ./dliteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/" 2 --log
#
#./dlSiteWeb.sh https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/linux/core/ 7 --log
#                      /            0            / 1 /     2     /   3  /   4  /   5   /  6  /  7 /   # curseur du cut-dir* 
# /0/1/2/3/4/5/6/7/ sont les positions du curseur de l'option "cut-dirs" de wget 
# Dans l'exemple précédente on fait un cut-dirs à la position #7 de l'url pour ignorer tous les fichiers ce qui se trouvent avant cette position.
# wget va recursivement télécharger fichiers et structure de repertoires aprés la position 7 de cette url et les enregistrer localement en les enregistrant sous : /le_chemin_de_mon_repertoire_de_travail/softwareupdate.vmware.com/
#
#./dlSiteWeb.sh https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/linux/core/ 7 un_repertoire_cible --log
# wget va recursivement télécharger fichiers et structure de repertoires aprés la position 7 de cette url et les enregistrer localement en les enregistrant sous : /le_chemin_de_mon_repertoire_de_travail/un_repertoire_cible/softwareupdate.vmware.com/

# Si les arguments ne sont pas fournis ou sont incorrects, le script affiche un message d'utilisation.

###########################################################################################

# Vérifier que 2 ou 4 arguments sont passés au script
if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <URL> <nombre de niveaux de répertoires distants parents à ignorer> <Répertoire_Cible> [--log]"
    exit 1
fi

# Vérifier que les deux premiers arguments ne sont pas vides
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <URL> <nombre de niveaux de répertoires distants à ignorer> <Répertoire_Cible>"
    exit 1
fi

URL=$1
CUT_DIRS=$2
REPERTOIRE_COURANT=$(pwd)
REPERTOIRE_CIBLE=""
LOG_FILE=""
CHEMIN_COMPLET=""

# Extraire le FQDN de l'URL
FQDN=$(echo $URL | cut -d/ -f3)
#echo "DEBUG : Le nom de domaine est : $FQDN"

# Vérifier si l'utilisateur a fourni un nom de répertoire cible pour sauvegarder le site web
if [ -n "$3" ] && [ "$3" != "--log" ]; then
    REPERTOIRE_CIBLE=$3

    if [ -d "$REPERTOIRE_CIBLE" ]; then
        echo "Le répertoire $REPERTOIRE_CIBLE existe déjà !"
        exit 0 # Quitter le script si le répertoire existe déjà
    else
        mkdir -p "$REPERTOIRE_CIBLE" # Créer le répertoire cible s'il n'existe pas
        echo "Le répertoire $REPERTOIRE_CIBLE a été créé !"
        # cd "$REPERTOIRE_CIBLE" # Aller dans le répertoire cible (décommenter si nécessaire)
    fi
fi

# Vérifier si l'option --log est passée
if [ "$4" == "--log" ] || [ "$3" == "--log" ]; then
    LOG_FILE=$(date +"%H_%M_%S_%d_%m_%Y_$FQDN.log")
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

# Adapter le chemin si l'utilisateur à fourni un repertoire cible pour sauvegarder les fichiers du site web 
if [ "$REPERTOIRE_CIBLE" == "" ]; then
        CHEMIN_COMPLET=$REPERTOIRE_COURANT/$FQDN
    else 
        CHEMIN_COMPLET=$REPERTOIRE_COURANT/$REPERTOIRE_CIBLE/$FQDN
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
    wget --recursive --no-parent --directory-prefix="$REPERTOIRE_CIBLE" --cut-dirs="$CUT_DIRS" --reject "index.html*" --timestamping "$base_url" 2>&1

	# -recursive : Télécharge les fichiers de manière récursive.
	# --no-parent : Empêche wget de remonter dans les répertoires parents.
	# --directory-prefix="$REPERTOIRE_CIBLE" : Spécifie le répertoire de destination.
	# --cut-dirs="$CUT_DIRS" : Spécifie le nombre de répertoires à supprimer de la structure de répertoires téléchargée.
	# --reject "index.html*" : Rejette les fichiers correspondant au motif spécifié.
	# --timestamping : Ne télécharge les fichiers que s'ils sont plus récents que les fichiers locaux.

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
            echo ""
            echo "------------------------------------------------------------"
            echo "File : $file_name"
            echo "Size : $human_readable_size_str"
            echo "------------------------------------------------------------"
            echo ""
            total_size=$((total_size + file_size))
            echo "Updated total size: $(human_readable_size $total_size)"
            total_nbFichier=$((total_nbFichier + 1))
        fi
    done <<< "$(find "$CHEMIN_COMPLET" -type f)"

    echo ""
    echo "--------------------------- FIN ---------------------------"
    echo "Taille totale : $(human_readable_size $total_size)"
    echo "Nb total de fichier : $total_nbFichier"
   echo "------------------------------------------------------------"
}

# Appeler la fonction pour traiter les fichiers
process_files $URL

# Appeler la fonction pour calculer les tailles des fichiers téléchargés en local
echo "---------------------------------------------------"
calculate_local_file_sizes

# Conserver le répertoire temporaire pour garder la structure et les fichiers téléchargés
echo "Les fichiers téléchargés et la structure des répertoires sont conservés dans le répertoire : $CHEMIN_COMPLET"
