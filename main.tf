provider "nomad" {
  address = var.nomad_provider_address
}

locals {
  datacenters = join(",", var.nomad_datacenters)
  minio_env_vars = join("\n",
    concat([
      "MINIO_ACCESS_KEY=${var.minio_access_key}",
      "MINIO_SECRET_KEY=${var.minio_secret_key}"
    ], var.minio_container_environment_variables)
  )
}

data "template_file" "nomad-job-minio" {

  template = file("${path.module}/conf/nomad/minio.hcl")

  vars = {
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.minio_container_image
    service_name = var.minio_service_name
    host         = var.minio_host
    port         = var.minio_port
    access_key   = var.minio_access_key
    secret_key   = var.minio_secret_key
    envs         = local.minio_env_vars

  }
}

resource "nomad_job" "nomad-job-minio" {
  jobspec = data.template_file.nomad-job-minio.rendered
}

