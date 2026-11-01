terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Las credenciales se leen del entorno o de tu perfil de AWS.
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "buzon" {
  bucket = var.bucket_name
}

# El buzón nunca debe ser accesible públicamente.
resource "aws_s3_bucket_public_access_block" "buzon" {
  bucket = aws_s3_bucket.buzon.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Respaldo del borrado que hace el panel: elimina lo que nunca se importó
# y limpia las subidas que quedaron incompletas.
resource "aws_s3_bucket_lifecycle_configuration" "buzon" {
  bucket = aws_s3_bucket.buzon.id

  rule {
    id     = "borrar-archivos-antiguos"
    status = "Enabled"

    filter {}

    expiration {
      days = var.dias_maximos_en_buzon
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
