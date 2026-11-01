# Infraestructura

| Carpeta | Contenido | Estado |
|---|---|---|
| `vps/` | Script de preparación y Docker Compose del VPS | En uso |
| `ovh/` | Plantilla de credenciales de la API de OVH | Opcional |

## VPS

1. Prepara el servidor con actualizaciones, firewall y Docker:

   ```sh
   ssh xdr-vps 'sudo bash -s' < infraestructura/vps/preparar.sh
   ```

2. Copia `vps/docker-compose.yml` a `~/xdr/` en el servidor y crea ahí su `.env` a partir de `vps/.env.example`, con una contraseña larga.
3. Levanta los servicios en esa carpeta con `sudo docker compose up -d`.

Para llegar a PostgreSQL desde la Mac, abre un túnel SSH:

```sh
ssh -N -L 5432:127.0.0.1:5432 xdr-vps
```

## Cuidados

- Nunca subas a git tokens ni archivos `.env`. El repo es público y `.gitignore` ya los excluye.
- Cada `.env` debe tener su `.env.example`.
