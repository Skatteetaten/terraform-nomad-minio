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

data "template_file" "nomad_job_minio" {

  template = file("${path.module}/conf/nomad/minio.hcl")

  vars = {
    datacenters     = local.datacenters
    namespace       = var.nomad_namespace
    host_volume     = var.nomad_host_volume
    image           = var.container_image
    service_name    = var.service_name
    host            = var.host
    port            = var.port
    access_key      = var.access_key
    secret_key      = var.secret_key
    data_dir        = var.data_dir
    envs            = local.minio_env_vars
    use_host_volume = var.use_host_volume
    use_canary      = var.use_canary
    upstreams = jsonencode(var.minio_upstreams)
  }
}

data "template_file" "nomad_job_mc" {

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

resource "nomad_job" "nomad_job_minio" {
  jobspec = data.template_file.nomad_job_minio.rendered
  detach  = false
}

resource "nomad_job" "nomad_job_mc" {
  jobspec     = data.template_file.nomad_job_mc.rendered
  detach      = false

  depends_on  = [
    nomad_job.nomad_job_minio
  ]
}

