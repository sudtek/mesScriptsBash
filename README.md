# mesScriptsBash
Une collection de petits scripts shell bash dédiées au web, au système ... visant à automatiser des manipulations fastidieuses ...

## Scripts web :

Scripts shell bash dédiés au web visant à automatiser des manipulations fastidieuses ...

- [evalTailleSiteWeb.sh](https://github.com/sudtek/webScripts/tree/c8e24cbc7036be943caabc140dda1b5e99603dbc/evalTailleSiteWeb) : Ce script va crawler / parcourir un site web via une URL et calculer la taille / volumétrie totale représenté par les fichiers pour un niveau donné de l’arborescence. Son but est de connaître la volumétrie nécessaire pour stocker avant d’envisager de le télécharger, cela évite les mauvaise surprise comme la saturation du volume de stockage ...

- [dlSiteWeb.sh](https://github.com/sudtek/webScripts/tree/38ed7dd5ce47f94d9409afbd2d29e9722efbe702/dlSiteWeb) : Ce script va recursivement télécharger les fichiers d'une URL fichiers et répliquer l'arborescence. Le log dresse un récapitulatif de la volumetrie detaillé et total des telechargements.J'utilise ce script aprés avoir evalué la taille du dl via le script [evalTailleSiteWeb](https://github.com/sudtek/webScripts/tree/c8e24cbc7036be943caabc140dda1b5e99603dbc/evalTailleSiteWeb)

## Scripts système :

Scripts shell bash dédiés au système  pour tester et bidouiller ...

- [qemu_static_ARM.sh]() : Ce script est un simple POC docker qui permet via un pull de qemu-user-static sur un PC hote x86, ajouter le greffon de facon permanente au systéme hote et faire un pull d'un conteneur aarch64. ATTENTION requier des priviléges pour fonctionner !
