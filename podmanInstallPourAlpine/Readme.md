# Installer podman sur distribution Alpine en rootless

## Description

Ces scripts ont pour but d'automatiser l'installation de podman (un clone de docker opensource) dans une distribution Alpine 3.2 et d'avoir des utilisateurs rootless qui sont capables de manipuler des containeurs sans être root. Alpine est connue pour sa faible taille, surface d'attaque, sa robustesse ... (sa lib musl ...) c'est une des distributions incontournable pour tout ce qui touche de prés ou de loin aux containeurs, Exemples :

- faire un pull Alpine pour créer un container.
- faire une VM dans un hyperviseur (vmware,proxmox,hyperv,Qemu ...) et y installer podman pour heberger ses containeurs.

... néanmoins pour les utilisateurs d'ubuntu et debian certains manipulations trés basiques peuvent vite prendre la tête surtout lorsque l'on manipule peut la distribution hote (ou tourne podman) et que l'on se concentre sur les containers.

## Donner pouvoir "doas" à un utilsateur :

[create_user_doas.sh](https://github.com/sudtek/mesScriptsBash/blob/136ecd972dfbcb708babcf512d78de23b82efea8/podmanInstallPourAlpine/create_user_doas.sh)

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


## Installer podman avec un utilsateur rootless :

[install_podman.sh](https://github.com/sudtek/mesScriptsBash/blob/136ecd972dfbcb708babcf512d78de23b82efea8/podmanInstallPourAlpine/install_podman.sh)

Prérequis : Avoir un utilsateur !! NON ROOT !! capable de lancer une commande via un "doas" si vous avez un doute avant de lancer le script faites ce simple test :

```
doas echo "doas Fonctionne pour : $(whoami) !"
```

Si vous lisez "doas Fonctionne pour : bernardo !" alors vous pouvez installer podman.


Ce script va installer podman dans la distribution Alpine, donner le droit à un utilisateur avec privilége mais NON ROOT !! capable de faire "doas" afin qu'il puisse manipuler podman sans avoir à faire doas tout le temps. Le nom de l'utilisateur vous sera demandé interactivement par le script pas besoin de le passer en argument.
Ce script vous posera une question optionelle concernant le numéro de ports minimum qui pourra être utilisé par defaut il interdira de faire des containeurs qui vont essayer d'utiliser des ports bas strictement inferieur au port 80 (C'est à adapter en fonction de vos besoin ...).

```
doas ./install_podman.sh
```

Avec la distribtion Alpine le service Podman doit être ajouté et activé pour être actif car sur Alpine c'est pas parce qu'on installe un service qu'il redémarera automatiquement au prochain reboot source [Howto enable and start services on Alpine linux](https://www.cyberciti.biz/faq/how-to-enable-and-start-services-on-alpine-linux/) mais vu que l'on a fait une installation en ROOTLESS -> Le service Podman en mode rootless doit être géré par l'utilisateur et non par le système. Cela signifie que le service doit être démarré par l'utilisateur et non par root.

Donc cette commande est uniquement valable en mode root standard et ne pourra pas lancer le service Podman aprés un reboot en mode ROOTLESS :
```
doas rc-update add podman default
```
au reboot si vous consultez les status : ```rc-status default``` Podman n'aura pas redémaré :
```
Runlevel: default
 acpid    [  started  ]
 crond    [  started  ]
 chronyd  [  started  ]
 cgroup   [  started  ]
 podman   [  stopped  ]**
 sshd     [  started  ]
```


_Note : Attention par defaut la distribution ALpine utilise par defaut sh et pas bash !_

## Licence
Ce projet est sous licence MIT.
