job "${service_name}" {

  type          = "service"
  datacenters   = "${datacenters}"
  namespace     = "${namespace}"

  group "s3" {
    network {
      mode = "bridge"
    }

    volume "persistence" {
      type      = "host"
      source    = "persistence"
      read_only = false
    }

    service {
      name = "${service_name}"
      port = "${port}"
      # https://docs.min.io/docs/minio-monitoring-guide.html
      check {
        expose    = true
        name      = "${service_name}-live"
        type      = "http"
        path      = "/minio/health/live"
        interval  = "10s"
        timeout   = "2s"
      }
      check {
        expose    = true
        name      = "${service_name}-ready"
        type      = "http"
        path      = "/minio/health/ready"
        interval  = "15s"
        timeout   = "4s"
      }
      connect {
        sidecar_service {}
      }
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "persistence"
        destination = "/local/data"
        read_only   = false
      }

      config {
        image             = "${image}"
        memory_hard_limit = 2048
        args              = [
          "server",
          "/local/data",
          "-address",
          "${host}:${port}"
        ]
      }
      template {
        destination = "local/data/.envs"
        change_mode = "noop"
        env         = true
        data        = <<EOF
${envs}
EOF
      }
      resources {
        cpu     = 200
        memory  = 1024
      }
    }
  }
}
