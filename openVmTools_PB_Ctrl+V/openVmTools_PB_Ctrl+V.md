openVmTools_PB_Ctrl+V.sh

29/01/2025 yannick SUDRIE

Description

BUT : Rectifier le PB de copier coller liés à une mauvaise installation des open vm tools qui se mélangent les claviers fr VS us avec VMWARE WORKSTATION.

Lorsqu'on fait un copier coller du PC hote vers la vm via le menu de vmware workstation : Edit->Paste

Le PB est encore plus probant si on fait une inception à plusieurs niveau via (nomachine, remina ...).

La vm invitée a un clavier fr azerty totalement fonctionnel, un copier coller entre deux terminal dans l'invité et parfaitement mappé fr <-> fr !

A contrario un Ctrl+C depuis l'hote suivi d'un Ctrl+V via le menu de vmware fait un maping vers l os invité en us  ... le texte et subtituer les a->q, ect ...

Exemple #1 : httpsM!!superuser:co,!auestions!ç-''"è!v,zqre)zorkstqtions)edit)pqste)uses)the)zrong)keyboqrd)lqyout

Exemple #2 : echo  %Pqssqge du clqvier en Frqncqis 11 %

Ce PB semble lié a une mauvaise installation open-vm-tools et/ou open-vm-tools-desktop et ce comportement rend facilement dingo l'utilisateur surtout si vous installez regulierement des VM ... ou faites un retour sur un snapshot antèrieur qui recharge les anciens vm-tools.

Voir la discution sur le site de superuser pour plus de details : https://superuser.com/questions/964437/vmware-workstations-edit-paste-uses-the-wrong-keyboard-layout


Exemple d'utilisation
./openVmTools_PB_Ctrl+V.sh

Licence
Ce script est sous licence MIT.
