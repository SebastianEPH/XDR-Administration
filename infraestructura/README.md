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

2. Crea tu `.env` de secretos en el proyecto, con una contraseña larga:

   ```sh
   cp infraestructura/vps/.env.example infraestructura/vps/.env
   ```

3. Envía la configuración al VPS y levanta los servicios:

   ```sh
   infraestructura/vps/desplegar.sh
   ```

Las contraseñas se cambian en `infraestructura/vps/.env`, y `desplegar.sh` las aplica en el servidor. Ese archivo no se sube a git, así que guárdalo también en tu gestor de contraseñas.

Para llegar a PostgreSQL desde la Mac, abre un túnel SSH:

```sh
ssh -N -L 5432:127.0.0.1:5432 xdr-vps
```

## Cuidados

- Nunca subas a git tokens ni archivos `.env`. El repo es público y `.gitignore` ya los excluye.
- Cada `.env` debe tener su `.env.example`.
