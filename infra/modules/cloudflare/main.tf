terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_r2_bucket" "buzon" {
  account_id = var.account_id
  name       = var.bucket_name
}

# Respaldo del borrado que hace el panel: elimina lo que nunca se importó
# y limpia las subidas que quedaron incompletas.
resource "cloudflare_r2_bucket_lifecycle" "buzon" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.buzon.name

  rules = [
    {
      id         = "borrar-archivos-antiguos"
      enabled    = true
      conditions = { prefix = "" }

      delete_objects_transition = {
        condition = {
          type    = "Age"
          max_age = var.dias_maximos_en_buzon * 86400 # en segundos
        }
      }

      abort_multipart_uploads_transition = {
        condition = {
          type    = "Age"
          max_age = 86400 # 1 día
        }
      }
    }
  ]
}
