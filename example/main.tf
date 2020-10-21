data "vault_generic_secret" "minio_secrets" {
  path  = "secret/minio"
}

module "minio" {
  source = "./.."

  # nomad
  nomad_datacenters               = ["dc1"]
  nomad_namespace                 = "default"
  nomad_host_volume               = "persistence"

  # minio
  service_name                    = "minio"
  host                            = "127.0.0.1"
  port                            = 9000
  container_image                 = "minio/minio:latest"
  access_key                      = data.vault_generic_secret.minio_secrets.data.access_key
  secret_key                      = data.vault_generic_secret.minio_secrets.data.secret_key
  data_dir                        = "/local/data"
  container_environment_variables = ["SOME_VAR_N1=some-value"]
  use_host_volume                 = true

  # minio client
  mc_service_name                 = "mc"
  mc_container_image              = "minio/mc:latest"
  buckets                         = ["one", "two"]
}
