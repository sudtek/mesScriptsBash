#!/bin/sh

# 27 février 2025
# But : installation rapide de podman (équivalent à docker opensource) sur alpine 3.21.2 64 bits du 08 janvier 2025
# On part du principe que vous avez déjà un user doas (équivalent à sudo chez alpine)

# Vérifier que le script est exécuté en root ou avec doas
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté avec les privilèges root ou avec doas (équivalent sudo)." >&2
    exit 1
fi

# Activer le community repository
# Rechercher une ligne contenant "mirror1" et "community" et la décommenter si nécessaire

#REPO_FILE="/etc/apk/repositories"
if grep -q '#.*mirror1.*community' "$REPO_FILE"; then
    sed -i 's/#\(.*mirror1.*community\)/\1/' "$REPO_FILE"
    echo "Le dépôt community a été activé."
else
    echo "Le dépôt community est déjà activé ou n'a pas été trouvé."
fi

# Activation community repo améliorée
# non à  revoir car decommante tout ...
#sed -i '/community/ s/^#//' /etc/apk/repositories


# Activer cgroups v2
echo "Configuration de cgroups v2..."
if ! grep -q '^rc_cgroup_mode="unified"' /etc/rc.conf; then
    echo 'rc_cgroup_mode="unified"' >> /etc/rc.conf
fi

# Activer le service cgroups
echo "Activation du service cgroups..."
rc-update add cgroups && rc-service cgroups start

# Mettre à jour les packages
apk update

# Installer Podman
# Vérifie si podman est déjà installé
if ! command -v podman &> /dev/null; then
    echo "Installation de Podman..."
    apk add podman
else
    echo "Podman est déjà installé !"
fi

# Configuration rootless
echo "Configuration du mode rootless..."
modprobe tun 2>/dev/null || true
if ! grep -q '^tun' /etc/modules; then
    echo "tun" >> /etc/modules
fi

# Demander le nom d'utilisateur
read -p "Entrez le nom d'utilisateur pour la configuration rootless: " USERNAME
if ! id "$USERNAME" &>/dev/null; then
    echo "Erreur: L'utilisateur $USERNAME n'existe pas !" >&2
    exit 1
fi

# Configurer subuid/subgid
#Gestion rootless sécurisée
if ! grep -q "^${USERNAME}:" /etc/subuid; then
    echo "${USERNAME}:100000:65536" > /etc/subuid
    echo "${USERNAME}:100000:65536" > /etc/subgid
fi


# Activer iptables
echo "Activation d'iptables..."
modprobe ip_tables 2>/dev/null || true

if ! grep -q '^ip_tables' /etc/modules; then
    echo "ip_tables" >> /etc/modules
fi

# Optionnel: Autoriser les ports < 1024
# Gestion POSIX de la confirmation
echo "Voulez-vous autoriser les ports < 1024 ? [y/N]"
read -r PORT_CHOICE
if echo "$PORT_CHOICE" | grep -iq "^y"; then
    MIN_PORT="80" # Valeur plus sécurisée que 0
    echo "net.ipv4.ip_unprivileged_port_start=${MIN_PORT}" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
fi

# Tester Podman
echo "Test de Podman avec hello-world..."
su - "$USERNAME" -c "podman run --rm hello-world"

echo "Installation de Podman terminée -> OK!"

echo "Ajout et activation du service Podman au reboot ! -> OK!"
# Attention cette rc-update est uniquement valable en mode root pour lancer des services systémes et ne pourra pas lancer le service utilisateur Podman aprés un reboot en mode ROOTLESS !
#doas rc-update add podman default
# Le service Podman en mode rootless doit être géré par l'utilisateur et non par le système. Cela signifie que le service doit être démarré par l'utilisateur et non par root.

# Créez un fichier de service utilisateur dans ~/.config/systemd/user/ (si vous utilisez systemd)
mkdir -p ~/.config/systemd/$(whoami)/
touch ~/.config/systemd/$(whoami)/podman.service

# Service utilisateur pour Podman en ROOTLESS
cat <<EOF > ~/.config/systemd/$(whoami)/podman.service
[Unit]
Description=Podman API Service
Requires=podman.socket

[Service]
ExecStart=/usr/bin/podman system service --time=0
Restart=on-failure

[Install]
WantedBy=default.target
EOF

#activer et démarrer le service 
systemctl --user enable podman.service
systemctl --user start podman.service

echo "Vous devriez peut-être redémarrer votre système pour vérifier que toutes les modifications prennent effet ..."
