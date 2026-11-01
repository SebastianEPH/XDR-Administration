variable "region" {
  description = "Región de AWS donde se crea el bucket."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre del bucket; debe ser único en todo AWS."
  type        = string
}

variable "dias_maximos_en_buzon" {
  description = "Días que un archivo puede quedar en el buzón antes de borrarse automáticamente."
  type        = number
  default     = 30

  validation {
    condition     = var.dias_maximos_en_buzon >= 1
    error_message = "Debe ser de al menos 1 día."
  }
}
