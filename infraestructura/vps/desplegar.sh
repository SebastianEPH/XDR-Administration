#!/usr/bin/env bash
# Envía la configuración de esta carpeta al VPS y levanta los servicios.
# El .env de esta carpeta es la fuente de los secretos. Uso:
#   infraestructura/vps/desplegar.sh
set -euo pipefail

SERVIDOR="${SERVIDOR:-xdr-vps}"
DESTINO="xdr"
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "Falta .env: cópialo de .env.example y completa los valores." >&2
  exit 1
fi
if grep -q 'CAMBIAR' .env; then
  echo "El .env todavía tiene valores de ejemplo." >&2
  exit 1
fi

ssh "$SERVIDOR" "mkdir -p ~/$DESTINO && chmod 700 ~/$DESTINO && (umask 077 && touch ~/$DESTINO/.env)"
scp -q docker-compose.yml "$SERVIDOR:$DESTINO/docker-compose.yml"
scp -q .env "$SERVIDOR:$DESTINO/.env"

ssh "$SERVIDOR" "DESTINO=$DESTINO bash -s" <<'REMOTO'
set -euo pipefail
cd ~/"$DESTINO"
chmod 600 .env
sudo docker compose up -d --quiet-pull

estado=""
for _ in $(seq 1 30); do
  estado=$(sudo docker inspect -f '{{.State.Health.Status}}' xdr-postgres)
  [ "$estado" = healthy ] && break
  sleep 2
done
if [ "$estado" != healthy ]; then
  echo "PostgreSQL no quedó saludable: $estado" >&2
  exit 1
fi

# PostgreSQL solo lee POSTGRES_PASSWORD al crear la base. Esto aplica el valor
# del .env también en despliegues posteriores, sin mostrarlo en los procesos.
usuario=$(grep '^POSTGRES_USER=' .env | cut -d= -f2-)
base=$(grep '^POSTGRES_DB=' .env | cut -d= -f2-)
clave=$(grep '^POSTGRES_PASSWORD=' .env | cut -d= -f2-)
printf "ALTER ROLE \"%s\" PASSWORD '%s';\n" "$usuario" "${clave//\'/\'\'}" \
  | sudo docker exec -i xdr-postgres psql -q -v ON_ERROR_STOP=1 -U "$usuario" -d "$base" >/dev/null

sudo docker compose ps --format '{{.Name}} {{.Status}}'
REMOTO
