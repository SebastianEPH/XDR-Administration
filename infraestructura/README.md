# Infraestructura

| Carpeta | Contenido | Estado |
|---|---|---|
| `vps/` | Script de preparación y Docker Compose del VPS | En uso |
| `ovh/` | Plantilla de credenciales de la API de OVH | Opcional |
| `aws/` | Bucket S3 con Terraform | Sin uso en la arquitectura actual |

## VPS

1. Prepara el servidor con actualizaciones, firewall y Docker:

   ```sh
   ssh xdr-vps 'sudo bash -s' < infraestructura/vps/preparar.sh
   ```

2. Copia `vps/docker-compose.yml` y `vps/.env.example` al servidor, crea su `.env` y define una contraseña larga.
3. Levanta los servicios en esa carpeta con `docker compose up -d`.

Para llegar a PostgreSQL desde la Mac, abre un túnel SSH:

```sh
ssh -N -L 5432:127.0.0.1:5432 xdr-vps
```

## Terraform

Terraform crea recursos de la nube a partir de archivos: describes lo que quieres y calcula qué debe crear, cambiar o borrar. Ahora solo lo usa la carpeta `aws/`, que no está desplegada.

| Comando | Qué hace |
|---|---|
| `terraform init` | Descarga el proveedor |
| `terraform plan` | Muestra los cambios sin aplicarlos |
| `terraform apply` | Aplica los cambios, previa confirmación |
| `terraform destroy` | Borra lo creado |

## Cuidados

- Nunca subas a git tokens, `.env`, `terraform.tfvars` ni `terraform.tfstate`. El repo es público y `.gitignore` ya los excluye.
- Cada `.env` debe tener su `.env.example`.
