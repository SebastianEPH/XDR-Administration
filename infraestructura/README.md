# Infraestructura

Terraform crea los recursos de la nube a partir de estos archivos: describes lo que quieres y calcula qué debe crear, cambiar o borrar.

## Conceptos

| Concepto | Qué es |
|---|---|
| Proveedor | Plugin que habla con una nube, en este caso Cloudflare |
| Recurso | Algo que se crea en la nube, como un bucket |
| Módulo | Conjunto reutilizable de recursos; aquí hay uno por nube |
| Variable | Valor configurable, sin escribirlo fijo en el código |
| Estado | Archivo `terraform.tfstate` donde Terraform recuerda lo que creó |

## Archivos

| Archivo | Contenido |
|---|---|
| `main.tf` | Proveedor y módulo que se despliega |
| `variables.tf` | Valores configurables |
| `outputs.tf` | Datos que se muestran al terminar |
| `modules/cloudflare/` | Bucket R2 y su regla de borrado automático |
| `.terraform.lock.hcl` | Versión exacta del proveedor; va en git |

## Primer despliegue

1. En Cloudflare, crea un token de API con el permiso **Workers R2 Storage: Edit** y copia el ID de tu cuenta.
2. Carga el token y prepara tus variables:

   ```sh
   cd infraestructura
   export CLOUDFLARE_API_TOKEN="tu-token"
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Escribe el ID de tu cuenta en `terraform.tfvars`.
4. Ejecuta los comandos:

   ```sh
   terraform init    # descarga el proveedor
   terraform plan    # muestra los cambios, sin aplicarlos
   terraform apply   # aplica los cambios, previa confirmación
   ```

`terraform destroy` borra todo lo creado. Falla si el bucket todavía tiene archivos.

## Cuidados

- Nunca subas a git el token, `terraform.tfvars` ni `terraform.tfstate`. El repo es público y `.gitignore` ya los excluye.
- El estado solo está en tu PC, así que inclúyelo en tus copias de seguridad.
- Lee siempre el resultado de `plan` antes de ejecutar `apply`.
