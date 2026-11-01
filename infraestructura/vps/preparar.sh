#!/usr/bin/env bash
# Prepara un VPS Ubuntu nuevo: actualizaciones, firewall y Docker.
# Se puede ejecutar más de una vez. Uso:
#   ssh ubuntu@IP 'sudo bash -s' < infraestructura/vps/preparar.sh
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

echo "== Actualizaciones =="
apt-get update -qq
apt-get -y -qq "${APT_OPTS[@]}" upgrade
apt-get -y -qq install ufw unattended-upgrades ca-certificates curl

cat > /etc/apt/apt.conf.d/20auto-upgrades <<'CONF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
CONF

echo "== Firewall =="
# SSH se permite antes de activar el firewall para no perder el acceso.
ufw allow 22/tcp comment 'SSH' >/dev/null
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw --force enable >/dev/null

echo "== Docker =="
if ! command -v docker >/dev/null; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  . /etc/os-release
  cat > /etc/apt/sources.list.d/docker.sources <<CONF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${VERSION_CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
CONF
  apt-get update -qq
  apt-get -y -qq install docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Docker se salta las reglas de ufw al publicar puertos. Por eso, por defecto,
# solo publica en localhost; exponer un puerto requiere indicarlo a propósito.
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'CONF'
{
  "ip": "127.0.0.1",
  "log-driver": "local",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
CONF
systemctl restart docker
systemctl enable --quiet docker

usermod -aG docker ubuntu

echo "== Listo =="
[ -f /var/run/reboot-required ] && echo "REINICIO_REQUERIDO" || echo "sin reinicio pendiente"
