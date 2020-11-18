module "minio" {
  source = "../.."

  # nomad
  nomad_datacenters               = ["dc1"]
  nomad_namespace                 = "default"
  nomad_host_volume               = "persistence"

  # minio
  service_name                    = "minio"
  host                            = "127.0.0.1"
  port                            = 9000
  container_image                 = "minio/minio:latest"
  vault_secret                    = {
                                      use_vault_provider     = true,
                                      vault_kv_policy_name   = "kv-secret",
                                      vault_kv_path          = "secret/data/minio",
                                      vault_kv_access_key    = "access_key",
                                      vault_kv_secret_key    = "secret_key"
                                    }
  data_dir                        = "/minio/data"
  container_environment_variables = ["SOME_VAR_N1=some-value"]
  use_host_volume                 = true
  use_canary                      = true
  cpu_proxy                       = 200
  memory_proxy                    = 128
  # minio client
  mc_service_name                 = "mc"
  mc_container_image              = "minio/mc:latest"
  buckets                         = ["one", "two"]
}
