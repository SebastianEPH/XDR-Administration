# Infraestructura

Terraform crea los recursos de la nube a partir de estos archivos: describes lo que quieres y calcula qué debe crear, cambiar o borrar.

Cada nube tiene su carpeta y su propio estado. Son alternativas: el XDR usa solo una, así que basta con desplegar la que elijas.

| Carpeta | Recursos |
|---|---|
| `cloudflare/` | Bucket R2 con borrado automático |
| `aws/` | Bucket S3 privado con borrado automático |

La API corre en el VPS, que se contrata aparte y no se administra desde estas carpetas.

## Conceptos

| Concepto | Qué es |
|---|---|
| Proveedor | Plugin que habla con una nube |
| Recurso | Algo que se crea en la nube, como un bucket |
| Variable | Valor configurable, sin escribirlo fijo en el código |
| Estado | Archivo `terraform.tfstate` donde Terraform recuerda lo que creó |

## Archivos de cada carpeta

| Archivo | Contenido |
|---|---|
| `main.tf` | Proveedor y recursos |
| `variables.tf` | Valores configurables |
| `outputs.tf` | Datos que se muestran al terminar |
| `.terraform.lock.hcl` | Versión exacta del proveedor; va en git |

## Desplegar en Cloudflare

1. Activa R2 en el panel de Cloudflare.
2. Crea un token de API personalizado con el permiso **Cuenta**, **Workers R2 Storage**, **Editar**.
3. Crea `cloudflare/.env` con tus datos:

   ```sh
   export CLOUDFLARE_API_TOKEN="tu-token"
   export TF_VAR_cloudflare_account_id="tu-account-id"
   ```

4. Ejecuta los comandos:

   ```sh
   cd infraestructura/cloudflare
   source .env
   terraform init    # descarga el proveedor
   terraform plan    # muestra los cambios, sin aplicarlos
   terraform apply   # aplica los cambios, previa confirmación
   ```

## Desplegar en AWS

1. Configura tus credenciales de AWS, por ejemplo con `aws configure`.
2. Crea tus variables y escribe un nombre de bucket único:

   ```sh
   cd infraestructura/aws
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Ejecuta `terraform init`, `terraform plan` y `terraform apply`.

## Cuidados

- Nunca subas a git tokens, `.env`, `terraform.tfvars` ni `terraform.tfstate`. El repo es público y `.gitignore` ya los excluye.
- El estado solo está en tu PC, así que inclúyelo en tus copias de seguridad.
- Lee siempre el resultado de `plan` antes de ejecutar `apply`.
- `terraform destroy` borra lo creado y falla si el bucket todavía tiene archivos.
