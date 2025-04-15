# linuxLeasyUpdate

## Description

`linuxLeasyUpdate` est un script bash simple conçu pour faciliter la mise à jour des systèmes Linux, en particulier sur les Raspberry Pi et les distributions Ubuntu. Il automatise les commandes `apt-get update`, `apt-get upgrade` et `apt-get dist-upgrade`, ce qui permet de gagner du temps et d'éviter de taper des commandes répétitives.

## Fonctionnalités

* Mise à jour des listes de paquets (`apt-get update`).
* Mise à niveau des paquets installés (`apt-get upgrade`).
* Mise à niveau de la distribution (gestion des dépendances et suppression des paquets obsolètes - `apt-get dist-upgrade`).
* Simple et facile à utiliser.

## Prérequis

* Un système Linux basé sur Debian (comme Ubuntu ou Raspberry Pi OS).
* Les privilèges sudo.

## Installation et utilisation

1.  Clonez le dépôt ou téléchargez le script `MAJ.sh` localement.
2.  Rendez le script exécutable :

    ```bash
    sudo chmod +x MAJ.sh
    ```

3.  Exécutez le script :

    ```bash
    ./MAJ.sh
    ```
