# mesScriptsBash
Une collection de petits scripts shell bash dédiées au web, au système ... visant à automatiser des manipulations fastidieuses ...

## Scripts web :

Scripts shell bash dédiés au web visant à automatiser des manipulations fastidieuses ...

- [evalTailleSiteWeb.sh](https://github.com/sudtek/webScripts/tree/c8e24cbc7036be943caabc140dda1b5e99603dbc/evalTailleSiteWeb) : Ce script va crawler / parcourir un site web via une URL et calculer la taille / volumétrie totale représenté par les fichiers pour un niveau donné de l’arborescence. Son but est de connaître la volumétrie nécessaire pour stocker avant d’envisager de le télécharger, cela évite les mauvaise surprise comme la saturation du volume de stockage ...

- [dlSiteWeb.sh](https://github.com/sudtek/webScripts/tree/38ed7dd5ce47f94d9409afbd2d29e9722efbe702/dlSiteWeb) : Ce script va recursivement télécharger les fichiers d'une URL fichiers et répliquer l'arborescence. Le log dresse un récapitulatif de la volumetrie detaillé et total des telechargements.J'utilise ce script aprés avoir evalué la taille du dl via le script [evalTailleSiteWeb](https://github.com/sudtek/webScripts/tree/c8e24cbc7036be943caabc140dda1b5e99603dbc/evalTailleSiteWeb)

## Scripts système :

Scripts shell bash dédiés au système ...

- [openVmTools_PB_Ctrl+V.sh](https://github.com/sudtek/mesScriptsBash/tree/76be8210a8da6c4ca5602ba6a69fca07ce888461/openVmTools_PB_Ctrl%2BV) : Si vous avez un pb de copier coller de l'hote vers l'invité avec une substitution du mapping clavier fr vers us ce script devrait résoudre ce PB trés pénible ...

- [keyMapFR.sh](https://github.com/sudtek/mesScriptsBash/tree/e4f355fcc90317bad9f7c9d4582a6ddb96ed773e/restoreKeyMapFR) : Dans l'environnement graphique Lubuntu il arrive régulièrement que l'on commute le clavier fr pour un autre selon la combo de touche que vous avez enfoncé (ouep c'est bien chiant...) ce script rectifie le tir restore le clavier fr il sufit de faire commuter via un alt+tab.

- [Installer podman sur Alpine] (https://github.com/sudtek/mesScriptsBash/tree/136ecd972dfbcb708babcf512d78de23b82efea8/podmanInstallPourAlpine) : Un simple script shell pour pouvoir installer podman (équivalent à docker) sur une distribution Alpine et avoir des utilisateurs rootless (Pas besoin que les utilisateurs soient root pour lancer et manipuler les containers).

## Pour tester et bidouiller ...
- [dockerAddQemuStaticARM.sh](https://github.com/sudtek/mesScriptsBash/tree/1ddd5ae851528df75a683ad730a7e292488d93d7/dockerAddQemuStaticARM) : Ce script est un simple POC docker qui permet via un pull de qemu-user-static sur un PC hote x86, ajouter le greffon de facon permanente au systéme hote et faire un pull d'un conteneur aarch64 ARM. (ATTENTION requier des priviléges pour fonctionner !)
