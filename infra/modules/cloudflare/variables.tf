variable "account_id" {
  description = "ID de la cuenta de Cloudflare."
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket."
  type        = string
}

variable "dias_maximos_en_buzon" {
  description = "Días antes de borrar automáticamente un archivo."
  type        = number

  validation {
    condition     = var.dias_maximos_en_buzon >= 1
    error_message = "Debe ser de al menos 1 día."
  }
}
