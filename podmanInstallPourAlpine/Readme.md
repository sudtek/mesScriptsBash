# Installer podman sur distribution Alpine en rootless

## Description

Ces scripts ont pour but d'automatiser l'installation de podman (un clone de docker opensource) en rootless dans une distribution Alpine 3.2 et d'avoir des utilisateurs rootless qui sont capables de manipuler (créer, administrer, gérer / limiter les ressources ...)  des containeurs de podman sans être root. Alpine est connue pour sa faible taille, surface d'attaque, sa robustesse ... (sa lib musl ...) c'est une des distributions incontournable pour tout ce qui touche de prés ou de loin aux containeurs, Exemples :

- faire un pull Alpine pour créer un container.
- faire une VM dans un hyperviseur (vmware,proxmox,hyperv,Qemu ...) et y installer podman pour heberger ses containeurs.

... néanmoins pour les utilisateurs d'ubuntu et debian certains manipulations trés basiques peuvent vite prendre la tête surtout lorsque l'on manipule peut la distribution hôte (ou tourne podman) et que l'on se concentre sur les containers.

## Créer & donner pouvoir "doas" à un utilisateur :

[create_user_doas.sh](create_user_doas.sh)

L'absence de "sudo" de base à pour équivalent "doas" mais n'est pas implanté par défaut j'ai donc créé deux scripts indépendants pour ne plus à avoir à chaque fois à rechercher comment faire. Si vous venez juste d'installer la distribution Alpine vous devez avant tout au moins créer 1er utilisateur via la commande adduser avant d'invoquer les scripts suivants. 

En root il vous faut créer l'utilisateur exemple "bernardo" qui manipulera podman et les containeurs :

```
adduser bernardo
```

oubien avec un utilisateur avec pouvoir deja capable de faire un "doas" :

```
doas adduser bernardo # équivalent à sudo adduser bernardo
```

_Note : Toujours fermer et réouvrir la session aprés avoir donné pouvoir à un utilisateur de faire un "doas" pour assurer une bonne màj._


## Installer podman en rootless :

[install_podman.sh](install_podman.sh)

Prérequis : Avoir un utilsateur !! NON ROOT !! capable de lancer une commande via un "doas" si vous avez un doute avant de lancer le script faites ce simple test :

```
doas echo "doas Fonctionne pour : $(whoami) !"
```

Si vous lisez "doas Fonctionne pour : bernardo !" alors vous pouvez installer podman.


Ce script va installer podman dans la distribution Alpine, donner le droit à un utilisateur avec privilége mais NON ROOT !! capable de faire "doas" afin qu'il puisse manipuler podman sans avoir à faire doas tout le temps. Le nom de l'utilisateur vous sera demandé interactivement par le script pas besoin de le passer en argument.
Ce script vous posera une question optionelle concernant le numéro de ports minimum qui pourra être utilisé par defaut il interdira de faire des containeurs qui vont essayer d'utiliser des ports bas strictement inferieur au port 1024 (C'est à adapter en fonction de vos besoin ...).

```
doas ./install_podman.sh
```

Avec la distribtion Alpine le service Podman doit être ajouté et activé pour être actif car sur Alpine c'est pas parce qu'on installe un service qu'il redémarera automatiquement au prochain reboot source [Howto enable and start services on Alpine linux](https://www.cyberciti.biz/faq/how-to-enable-and-start-services-on-alpine-linux/) mais vu que l'on a fait une installation en ROOTLESS -> Le service Podman en mode rootless doit être géré par l'utilisateur et non par le système. Cela signifie que le service doit être démarré par l'utilisateur et non par root.

Donc cette commande est uniquement valable en mode root pour lancer des services systémes et ne pourra pas lancer le service utilisateur Podman aprés un reboot en mode ROOTLESS :
```
doas rc-update add podman default
```
au reboot si vous consultez les status : ```rc-status default``` Podman n'a pas redémaré :
```
Runlevel: default
 acpid    [  started  ]
 crond    [  started  ]
 chronyd  [  started  ]
 cgroup   [  started  ]
 podman   [  stopped  ]**
 sshd     [  started  ]
```


_Note : Attention par defaut la distribution ALpine utilise sh et pas bash !_

## Ajouter un utilisateur pour qu'il puisse utiliser podman en rootless :
[add_user_podman.sh](add_user_rootless.sh)

Prérequis : 
- #1 Ce script doit être invoqué avec un utilisateur qui à des privilèges (doas). 
- #2 Podman doit être installé et fonctionnel.
- #3 L'utilisateur à ajouter à podman doit exister sur le systéme.

On peut invoquer ce script de deux facons :
- #1 soit en fournissant en argument le nom de l'utilisateur qui serra chargé piloter podman : ```doas ./add_user_rootless.sh bernardo```
- #2 soit sans argument : ```doas ./add_user_rootless.sh```  le nom de l'utilisateur devra être saisi interactivement.


## En cas de PB "WARN[0000] "/" is not a shared mount"
[fix_shared_mount.sh](fix_shared_mount.sh)

Les conteneurs sous Linux Alpine peuvent nécessiter que les systèmes de fichiers soient montés avec une propagation différente de la valeur par défaut du noyau, qui est 'private'. 
Si vous rencontrez l'avertissement suivant :
```WARN[0000] "/" is not a shared mount, this could cause issues or missing mounts with rootless containers```

Note : J'ai cette erreur lorsque je fais un ```podman info``` uniquement avec un utilisateur de test lambda qui peut faire un doas, utiliser podman en rootless ... mais pas depuis un autre utilisateur qui lui qui a installé podman en rootless ... donc attention il ya peut-être un bug plus complexe ... car mes deux utilisateurs ont subits exactement les mêmes scripts pour leur création !

Cela signifie que le montage de votre partition racine (/) n'utilise pas l'option shared, ce qui peut entraîner des problèmes ou des montages manquants avec les conteneurs rootless. Pour résoudre ce problème temporairement sur le système en cours d'exécution, vous pouvez utiliser la commande suivante :

```mount --make-rshared /``` 

Ensuite, réessayez la commande qui a provoqué l'avertissement. Pour vérifier si le montage est bien en mode shared, vous pouvez utiliser :
```findmnt -o PROPAGATION /```

Cela devrait afficher shared sous la colonne PROPAGATION. Pour une solution permanente, après la mise à jour d'OpenRC (version supérieure à 0.54.2-r1), vous devez éditer le fichier /etc/fstab et ajouter l'option shared à la partition racine :

```/dev/sda2 / ext4 rw,relatime,shared 0 1```

Après avoir redémarré, vérifiez à nouveau la propagation pour vous assurer que le montage est bien configuré en mode shared.

## Annexes  
- Alpine-linux-cheat-sheet [https://github.com/masoudei/alpine-linux-cheat-sheet](https://github.com/masoudei/alpine-linux-cheat-sheet)
- Le WIKI Podman [https://wiki.alpinelinux.org/wiki/Podman](https://wiki.alpinelinux.org/wiki/Podman)

## Licence
Ce projet est sous licence MIT.
