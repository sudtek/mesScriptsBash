#!/bin/bash

# 16/01/2025
#
# BUT : POC pour tester etconfigurer qemu-user-static sur un PC hote x86 afin de télécharger et tester un conteneur aarch64
# ATTENTION le container qemu-user-static requier un droit --privileged pour gréfer une aarch64 à l'hote d'une facon PERMANENTE dans /proc/sys/fs/binfmt_misc/qemu-aarch64 -> donc il y a une faible probabilité que cela fonctionne sur un systéme tiers que vous ne controlez pas et qui ne permet pas l'option --privileged
# Ce POC est donc juste pour faire un équivalent à "Helloworld" et affichera "aarch64" dans la console si tout a fonctioné correctement.
# 
#
# Architecture hote :
# Linux lenovo2 5.4.0-200-generic #220-Ubuntu SMP Fri Sep 27 13:19:16 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
# 
# Docker version :
# Client: Docker Engine - Community
#  Version:           27.4.1
#  API version:       1.47
#  Go version:        go1.22.10
#  Git commit:        b9d17ea
#  Built:             Tue Dec 17 15:45:52 2024
#  OS/Arch:           linux/amd64
#  Context:           default
# 
# Server: Docker Engine - Community
#  Engine:
#   Version:          27.4.1
#   API version:      1.47 (minimum version 1.24)
#   Go version:       go1.22.10
#   Git commit:       c710b88
#   Built:            Tue Dec 17 15:45:52 2024
#   OS/Arch:          linux/amd64
#   Experimental:     false
#  containerd:
#  Version:          1.7.24
#   GitCommit:        88bf19b2105c8b17560993bee28a01ddc2f97182
#  runc:
#   Version:          1.2.2
#   GitCommit:        v1.2.2-0-g7cb3632
#  docker-init:
#   Version:          0.19.0
#   GitCommit:        de40ad0

#

# 
# Ajout permanent de l'architecture ARM arch64 à l'hote 
echo "Pull et ajout permanent de l'architecture ARM arch64 à l'hote (ssi option --privileged authorisée !)"
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Vérifier la configuration de binfmt_misc
if [ -f /proc/sys/fs/binfmt_misc/qemu-aarch64 ]; then
    echo " OK -> qemu-user-static est configuré pour ARM64 !!"
else
    echo "Erreur : qemu-user-static n'est pas configuré pour ARM64."
    exit 1
fi

# Tirer une image Docker compatible avec l'architecture linux/amd64 et ARM64
echo "Pull d'une image Docker compatible avec l'architecture linux/amd64 et ARM64"
docker pull ubuntu:latest

# Exécuter un conteneur Docker ARM64 sur un hôte x86_64
docker run --rm -t --platform linux/arm64 ubuntu:latest uname -m
echo "Votre console doit afficher -> "aarch64" si tout est OK !"
