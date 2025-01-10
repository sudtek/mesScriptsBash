# dliteWeb.sh
06/01/2025
yannick SUDRIE

## Description

Ce script Bash parcourt un site web spécifié par une URL, télécharge la structure de répertoire et les fichiers. Il accepte trois arguments :
1. L'URL du site web à parcourir.
2. Le nombre de niveaux de répertoires à ignorer dans l'URL.
3. Option du nom de répertoire où télécharger les fichiers.
4. Option `--log` pour un suivi du téléchargement.

Le script utilise `wget` pour télécharger les fichiers et `curl` pour obtenir les tailles des fichiers. Les fichiers téléchargés sont enregistrés dans un répertoire temporaire, qui est conservé à la fin du script pour garantir que la structure et les fichiers téléchargés sont conservés.

## Exemple d'utilisation

```
./dliteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/"
```
```
./dliteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" --log
```
```
./dliteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 4 --log
```
```
./dliteWeb.sh "https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/" 4 monRepertoire --log
```

## Arguments

1. `<URL>` : L'URL du site web à parcourir.
2. `<nombre de niveaux de répertoires distants à ignorer>` : Le nombre de niveaux de répertoires à ignorer dans l'URL.
3. `<Répertoire_Cible>` (optionnel) : Le répertoire où télécharger les fichiers.
4. `[--log]` (optionnel) : Active la journalisation des opérations.

## Fonctionnalités

- **Téléchargement récursif** : Utilise `wget` pour télécharger les fichiers de manière récursive.
- **Journalisation** : Option `--log` pour enregistrer les opérations dans un fichier de journal.
- **Calcul des tailles des fichiers** : Calcule et affiche les tailles des fichiers téléchargés en local.

## Fonctions

- `get_file_size()` : Obtient la taille d'un fichier à partir de son URL.
- `human_readable_size()` : Convertit la taille en une forme lisible par un humain.
- `get_file_name()` : Extrait le nom du fichier en cours de traitement.
- `process_files()` : Parcourt les fichiers et les télécharge.
- `calculate_local_file_sizes()` : Calcule les tailles des fichiers téléchargés en local.

## Exemple de sortie
```
Processing URL: https://softwareupdate.vmware.com/cds/vmw-desktop/player/12.0.0/2985596/
DEBUG : ../softwareupdate.vmware.com/ !!
File : example.txt
Size : 10 Mo
Updated total size: 10 Mo
Taille totale : 10 Mo
Nb total de fichier : 1
```

Les fichiers téléchargés et la structure des répertoires sont conservés dans le répertoire : 
```/chemin/actuel/softwareupdate.vmware.com/```
ou
```/chemin/actuel/<RepertoireCible>/softwareupdate.vmware.com/``` si vous avez precisé l'option <RepertoireCible>

## Licence
Ce projet est sous licence MIT.
