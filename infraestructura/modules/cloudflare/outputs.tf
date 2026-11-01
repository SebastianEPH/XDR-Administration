output "bucket_name" {
  description = "Nombre del bucket creado."
  value       = cloudflare_r2_bucket.buzon.name
}
