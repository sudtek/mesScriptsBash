# Podman Info Checker

Un script pour vérifier l'état de Podman (mode rootless et SELinux) en utilisant `podman info`.

## Problématique

Lors de l'utilisation de `podman info --format`, certains champs (comme `selinuxEnabled`) ne sont pas accessibles via les templates Go, bien qu'ils apparaissent dans la sortie JSON. Ce script démontre comment contourner cette limitation en utilisant `jq`.

## Utilisation

1. Téléchargez le script :
   ``` wget https://github.com/votre-utilisateur/podman-info-checker/raw/main/check_podman_info.sh```

Contexte :
Lors de l'utilisation de podman info --format pour extraire des informations spécifiques (comme l'état de SELinux ou le mode rootless), il est nécessaire d'utiliser des templates Go. Cependant, il existe des subtilités importantes à prendre en compte :

Casse des champs :

Les templates Go nécessitent que les noms de champs commencent par une majuscule pour être accessibles via la réflexion.

Par exemple, bien que la sortie JSON montre .host.security.rootless, le template Go doit utiliser .Host.Security.Rootless.

Champs non accessibles :

Certains champs, comme selinuxEnabled, apparaissent dans la sortie JSON mais ne sont pas accessibles via les templates Go. Cela est dû au fait que ces champs ne sont pas exportés dans la structure Go interne de Podman.

Solution alternative :

Pour les champs inaccessibles via les templates Go, il est recommandé d'utiliser jq pour extraire les valeurs directement à partir de la sortie JSON.

Pour visualiser correctement la structure comme un json il faut installer ```jq $(doas apk add jq)``` et visualiser / exporter le json avec ```podman info --format json | jq .```


Script exemple explicite
Voici un script bien documenté qui illustre la problématique et fournit une solution fonctionnelle :

```
#!/bin/sh

# Script pour vérifier l'état de Podman (rootless et SELinux)
# Auteur : yannick sudrie
# Date : 13 / mars / 2025
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
```

Explication du script
Fonctions utilitaires :

get_valeur_template : Utilise podman info --format pour extraire une valeur via un template Go.

get_valeur_json : Utilise jq pour extraire une valeur directement à partir du JSON généré par podman info.

Vérification du mode rootless :

Le script utilise un template Go pour extraire .Host.Security.Rootless, car ce champ est accessible via la réflexion.

Vérification de l'état de SELinux :

Le script utilise jq pour extraire .host.security.selinuxEnabled, car ce champ n'est pas accessible via les templates Go.

Démonstration d'une erreur :

Le script tente d'utiliser un template Go non valide ({{.Host.Security.SelinuxEnabled}}) pour illustrer l'erreur rencontrée.

Sortie attendue du script
Si Podman est en mode rootless et que SELinux est désactivé, la sortie sera :

```
DEBUG - Mode rootless (template Go) : true
OK -> Podman est en mode rootless.
DEBUG - SELinux activé (jq) : false
NOK -> SELinux n'est pas activé.
Tentative d'utilisation d'un template Go non valide :
Error: template: info:1:7: executing "info" at <.Host.Security.SelinuxEnabled>: can't evaluate field SelinuxEnabled in type define.SecurityInfo
Erreur : Champ SelinuxEnabled inaccessible via template Go.
Script terminé.
```
