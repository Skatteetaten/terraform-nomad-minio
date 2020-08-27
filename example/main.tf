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
  access_key                      = "minio"
  secret_key                      = "minio123"
  container_environment_variables = ["SOME_VAR_N1=some-value"]

  # minio client
  mc_service_name                 = "mc"
  mc_container_image              = "minio/mc:latest"
  buckets                         = ["one", "two"]
}
