locals {
  datacenters = join(",", var.nomad_datacenters)
  minio_env_vars = join("\n",
    concat([
      "MINIO_ACCESS_KEY=${var.access_key}",
      "MINIO_SECRET_KEY=${var.secret_key}"
    ], var.container_environment_variables)
  )
  mc_env_vars = join("\n",
    concat([
      "MINIO_ACCESS_KEY=${var.access_key}",
      "MINIO_SECRET_KEY=${var.secret_key}"
    ], var.mc_container_environment_variables)
  )

  mc_formatted_bucket_list = formatlist("LOCALMINIO/%s", var.buckets)
  mc_add_config_command = concat(
    [
      "mc",
      "config",
      "host",
      "add",
      "LOCALMINIO",
      "http://${var.host}:${var.port}",
      "$MINIO_ACCESS_KEY",
      "$MINIO_SECRET_KEY",
  ])
  mc_create_bucket_command = concat(["mc", "mb", "-p"], local.mc_formatted_bucket_list)
  command                  = join(" ", concat(local.mc_add_config_command, ["&&"], local.mc_create_bucket_command))
}

data "template_file" "nomad-job-minio" {

  template = file("${path.module}/conf/nomad/minio.hcl")

  vars = {
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.container_image
    service_name = var.service_name
    host         = var.host
    port         = var.port
    access_key   = var.access_key
    secret_key   = var.secret_key
    envs         = local.minio_env_vars

  }
}

data "template_file" "nomad-job-mc" {

  template = file("${path.module}/conf/nomad/mc.hcl")

  vars = {
    service_name       = var.mc_service_name
    minio_service_name = var.service_name
    datacenters        = local.datacenters
    namespace          = var.nomad_namespace
    image              = var.mc_container_image

    access_key = var.access_key
    secret_key = var.secret_key
    envs       = local.mc_env_vars

    command = local.command
  }
}

resource "nomad_job" "nomad-job-minio" {
  jobspec = data.template_file.nomad-job-minio.rendered
  detach  = false
}

resource "nomad_job" "nomad-job-mc" {
  jobspec     = data.template_file.nomad-job-mc.rendered
  detach      = false

  depends_on  = [
    nomad_job.nomad-job-minio
  ]
}
