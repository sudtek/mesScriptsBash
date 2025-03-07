#!/bin/sh

# 06 mars 2025
# v 0.2
#
# But : installation rapide de podman (équivalent à docker opensource) sur alpine 3.21.2 64 bits du 08 janvier 2025
# On part du principe que vous avez déjà un user doas (équivalent à sudo chez alpine)

# Vérifier que le script est exécuté avec doas
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté avec les privilèges avec doas (équivalent sudo) et PAS DEPUIS ROOT !" >&2
    exit 1
fi

# Vérifier si Podman est déjà en cours d'exécution
if rc-service podman status > /dev/null 2>&1; then
    echo "Podman est déjà en cours d'exécution. Arrêtez le service et /ou désinstaller podman avant de faire une nouvelle installation." >&2
    exit 1
fi


REPO_FILE="/etc/apk/repositories"

# Activer le community repository
if grep -q '#.*mirror1.*community' "$REPO_FILE"; then
    sed -i 's/#\(.*mirror1.*community\)/\1/' "$REPO_FILE"
    echo "Le dépôt community a été activé."
else
    echo "Le dépôt community est déjà activé ou n'a pas été trouvé."
fi

# cgroups v2
# Toutes les informations pour cgroups version 2, sont disponible dasn Documentation/cgroups-v2.txt dasn le kernel linux
# Dans le fichier /etc/rc.conf il ya une section # LINUX CGROUPS RESOURCE MANAGEMENT ou il est possible de fixer 
# la taille mémoire et le PID maximum pour un service si on désire eviter que Podman puisse consommer toutes les ressources systeme
# mais Attention toutes les modifications apportées dans le fichier /etc/rc.conf sont globales et pas au niveau des utilisateurs podman :
# 
# rc_cgroup_settings="
# memory.max 10485760
# pids.max max

echo "Configurer cgroups en v2 ..."
if ! grep -q '^rc_cgroup_mode="unified"' /etc/rc.conf; then
    echo 'rc_cgroup_mode="unified"' >> /etc/rc.conf
fi
# Activer le service cgroups
echo "Activation du service cgroups..."
rc-update add cgroups && rc-service cgroups start

# Mettre à jour les packages
apk update

# Installer Podman
if ! command -v podman &> /dev/null; then
    echo "Installation de Podman..."
    apk add podman
else
    echo "Podman est déjà installé !"
fi

# Activer iptables
echo "Activation d'iptables..."
modprobe ip_tables 2>/dev/null || true

if ! grep -q '^ip_tables' /etc/modules; then
    echo "ip_tables" >> /etc/modules
fi

# Optionnel: Autoriser les ports < 1024
echo "Voulez-vous autoriser les ports < 1024 ? [y/N]"
read -r PORT_CHOICE
if echo "$PORT_CHOICE" | grep -iq "^y"; then
    MIN_PORT="80"
    echo "net.ipv4.ip_unprivileged_port_start=${MIN_PORT}" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
fi

# Créer un fichier de service pour Podman en mode rootless
doas touch /etc/init.d/podman-rootless

doas cat <<EOF > /etc/init.d/podman-rootless
#!/sbin/openrc-run

description="Podman rootless service"

depend() {
    need localmount
    after bootmisc
}

start() {
    ebegin "Starting Podman rootless service"
    /usr/bin/podman system service --time=0 &
    eend $?
}

stop() {
    ebegin "Stopping Podman rootless service"
    pkill -f "podman system service --time=0"
    eend $?
}
EOF

# Fixer les permissions d'exécution au fichier
doas chmod +x /etc/init.d/podman-rootless

# Ajouter le service au démarrage
doas rc-update add podman-rootless default

# Démarrer le service manuellement
doas rc-service podman-rootless start

# Vérifier que le service fonctionne
doas rc-service podman-rootless status

echo "Installation de Podman terminée -> OK !"
echo "Maintenant : "
echo "#1 Vous devriez redémarrer votre système pour vérifier que toutes les modifications prennent effet ..."
echo "#2 Aprés le reboot il faudra ajouter des utilisateurs à podman rootless via le script add_user_podman.sh ! "
