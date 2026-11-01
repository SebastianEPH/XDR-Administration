variable "cloudflare_account_id" {
  description = "ID de la cuenta de Cloudflare."
  type        = string
}

variable "bucket_name" {
  description = "Nombre del bucket que funciona como buzón."
  type        = string
  default     = "xdr-buzon"
}

variable "dias_maximos_en_buzon" {
  description = "Días que un archivo puede quedar en el buzón antes de borrarse automáticamente."
  type        = number
  default     = 30
}
