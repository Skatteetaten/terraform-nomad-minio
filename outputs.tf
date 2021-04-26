output "minio_service_name" {
  description = "Minio service name"
  value       = var.service_name
}

output "minio_access_key" {
  description = "Minio access key"
  value       = var.access_key
  sensitive   = true
}

output "minio_secret_key" {
  description = "Minio secret key"
  value       = var.secret_key
  sensitive   = true
}

output "minio_port" {
  description = "Minio port number"
  value       = var.port
}
