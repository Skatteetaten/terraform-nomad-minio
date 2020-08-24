job "${service_name}" {

  type = "batch"
  datacenters = "${datacenters}"
  namespace = "${namespace}"

  group "mc" {

    service {
      name = "${service_name}"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "${minio_service_name}"
              local_bind_port = 9000
            }
          }
        }
      }
    }

    network {
      mode = "bridge"
    }

    task "mc-create-buckets" {
      driver = "docker"
      config {
        image = "minio/mc:latest"
        entrypoint = [
          "/bin/sh",
          "-c",
          "${command}"
        ]
      }
      template {
        // todo: put under `local/secrets`
        destination = "local/data/.envs"
        change_mode = "noop"
        env = true
        data = <<EOF
${envs}
EOF
      }
    }
  }
}
