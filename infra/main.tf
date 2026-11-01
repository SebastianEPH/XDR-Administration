terraform {
  required_version = ">= 1.9"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# El token se lee de la variable de entorno CLOUDFLARE_API_TOKEN.
provider "cloudflare" {}

module "buzon" {
  source = "./modules/cloudflare"

  account_id            = var.cloudflare_account_id
  bucket_name           = var.bucket_name
  dias_maximos_en_buzon = var.dias_maximos_en_buzon
}
