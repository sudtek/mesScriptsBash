# evalTailleSiteWeb.sh
06/01/2025
yannick SUDRIE

## Description
Ce script parcourt un site web spécifié par une URL et calcule la taille totale des fichiers sans les télécharger ni créer de répertoires locaux. Il accepte minimum deux arguments maximum trois arguments  :

1. L'URL du site web à parcourir.
2. Le nombre de niveaux de répertoires à ignorer dans l'URL.
3. --log  -> Active le logging. Si cette option est passée en troisième argument, le script génère un fichier de log avec un nom de fichier au format HH_MM_SS_JJ_MM_AAAA_FQDN.log.

Le script affiche les tailles des fichiers et la taille totale dans une forme lisible par un humain. Si l'option --log est activée, les messages de log sont enregistrés dans un fichier de log.   

Le script utilise wget en mode spider pour lister les fichiers et curl pour obtenir les tailles des fichiers. Les répertoires créés par wget sont enregistrés dans un répertoire temporaire, qui est supprimé à la fin du script pour garantir qu'aucun fichier ou répertoire local n'est créé.

## Exemple d'utilisation
./evalTailleSiteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 6

./evalTailleSiteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 6 --log 

## Prérequis
wget
curl
awk
basename

## Installation
Clonez ce dépôt :

git clone https://github.com/votre-utilisateur/votre-depot.git
cd votre-depot
Rendez le script exécutable :

chmod +x evalTailleSiteWeb.sh

## Utilisation
Exécutez le script avec les arguments nécessaires :

./evalTailleSiteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 6
Pour activer le logging, ajoutez l'option --log :

./evalTailleSiteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 6 --log

## Fonctionnalités
get_file_size() : Fonction pour obtenir la taille d'un fichier.
human_readable_size() : Fonction pour convertir la taille en une forme lisible par un humain.
get_file_name() : Fonction pour extraire le nom du fichier en cours de traitement.
process_files() : Fonction pour parcourir les fichiers et obtenir leurs tailles.
show_loading_animation() : Fonction pour afficher une animation de chargement.

## Exemple de sortie
Processing URL: https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/
wget output: ...
File: VMware-player-12.0.0-2985596.exe.tar
Size: 70 Mo
Updated total size: 70 Mo
File: metadata.xml.gz
Size: 132 Mo
Updated total size: 202 Mo
Taille totale : 202 Mo


## Licence
Ce projet est sous licence MIT.
