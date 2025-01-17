# dockeraddQemuStaticARM.sh
16/01/2025
yannick SUDRIE

## Description
Ce script est un simple POC pour docker qui permet de tester, installer et jouer avec qemu-user-static sur un PC hote x86.

Par défaut si vous essayez de faire un pull d'une image d'une architecture arm depuis votre pc sous X86 :

```
# Exécuter un conteneur Docker ARM64 sur un hôte x86_64
docker run --rm -t --platform linux/arm64 ubuntu:latest uname -m
```
Vous allez obtenir un message d'erreur un poil cryptique : 

[No matching manifest for linux/arm64/v8 in the manifest list entries](https://forums.docker.com/t/how-to-fix-no-matching-manifest-ubuntu-22-04/128569) 

Cet "erreur / message" est documenté sur le forum de docker mais bon elle est pas franchement explicite ->  docker vous informe juste que vous ne pouvez pas prétendre faire un pull de cette image docker basée sur l'architecture ARM car elle n'est pas interprétable par votre systéme X86.
D'ou l'interet d'utiliser qemu-user-static mais ATTENTION le container qemu-user-static requier de pouvoir faire une élévation de droit via l'option **--privileged** pour gréfer à l'hote de facon PERMANENTE et PERSISTANTE après reboot une gestion de aarch64 dans /proc/sys/fs/binfmt_misc/qemu-aarch64
Donc il y a une trés faible probabilité que ce POC fonctionne sur un systéme tiers dont vous nêtes pas root et qui ne permet pas l'option --privileged. Si ce POC passe sur un docker tiers c'est qu'il est permissif ...
Ce POC est donc juste équivalent à "Helloworld" et affichera "aarch64" dans la console si tout a fonctioné correctement.
Vous devriez pouvoir faire des pull pour ARM sur votre X86 sans plus avoir l'erreur de "manifest".


## Exemple d'utilisation
```
./dockeraddQemuStaticARM.sh
```

## Exemple de sortie

Si vous lisez :
```
aarch64 
```
C'est que les grefons pour ARM ont correctement été ajoutés et que vouspouvez tester des containeurs ARM sur votre PC X86.

## Licence
Ce script est sous licence MIT.
