module "minio" {
  source = "./.."

  # nomad
  nomad_datacenters               = ["dc1"]
  nomad_namespace                 = "default"

  # minio
  service_name                    = "minio"
  host                            = "127.0.0.1"
  port                            = 9000
  container_image                 = "minio/minio:latest"
  access_key                      = var.access_key
  secret_key                      = var.secret_key
  container_environment_variables = ["SOME_VAR_N1=some-value"]

  # minio client
  mc_service_name                 = "mc"
  mc_container_image              = "minio/mc:latest"
  buckets                         = ["one", "two"]
}

output "minio_service_name"{
  description = "Minio service name"
  value       = module.minio.minio_service_name
}

output "minio_access_key" {
  description = "Minio access key"
  value       = module.minio.minio_access_key
  sensitive   = true
}

output "minio_secret_key" {
  description = "Minio secret key"
  value       = module.minio.minio_secret_key
  sensitive   = true
}
