job "${service_name}" {

  type          = "service"
  datacenters   = "${datacenters}"
  namespace     = "${namespace}"

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "12m"
    progress_deadline = "15m"
%{ if use_canary }
    canary            = 1
    auto_promote      = true
    auto_revert       = true
%{ endif }
    stagger           = "30s"
  }

  group "s3" {
    network {
      mode = "bridge"
    }

  %{ if use_host_volume }
    volume "persistence" {
      type      = "host"
      source    = "${host_volume}"
      read_only = false
    }
  %{ endif }

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
        sidecar_service {
          proxy {
 %{ for upstream in jsondecode(upstreams) }
            upstreams {
              destination_name = "${upstream.service_name}"
              local_bind_port  = "${upstream.port}"
            }
%{ endfor }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

  %{ if use_vault_provider }
      vault {
        policies = "${vault_kv_policy_name}"
      }
  %{ endif }

  %{ if use_host_volume }
      volume_mount {
        volume      = "persistence"
        destination = "${data_dir}"
        read_only   = false
      }
  %{ endif }

      config {
        image             = "${image}"
        memory_hard_limit = 2048
        args              = [
          "server",
          "${data_dir}",
          "-address",
          "${host}:${port}"
        ]
      }
      template {
        destination = "secrets/.envs"
        change_mode = "noop"
        env         = true
        data        = <<EOF
%{ if use_vault_provider }
{{ with secret "${vault_kv_path}" }}
MINIO_ACCESS_KEY="{{ .Data.data.${vault_kv_access_key} }}"
MINIO_SECRET_KEY="{{ .Data.data.${vault_kv_secret_key} }}"
{{ end }}
%{ else }
MINIO_ACCESS_KEY="${access_key}"
MINIO_SECRET_KEY="${secret_key}"
%{ endif }
${ envs }
EOF
      }
      resources {
        cpu     = ${cpu}
        memory  = ${memory}
      }
    }
  }
}
