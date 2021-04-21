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
      port "expose_check1" {
        to = -1
      }
      port "expose_check2" {
        to = -1
      }
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
      tags = [
      %{for tag in consul_tags }
      "${tag}",
      %{endfor}
      ]
      connect {
        sidecar_service {
          proxy {
 %{ for upstream in jsondecode(upstreams) }
            upstreams {
              destination_name = "${upstream.service_name}"
              local_bind_port  = "${upstream.port}"
            }
%{ endfor }
            expose {
              path {
                path            = "/minio/health/live"
                protocol        = "http"
                local_path_port = ${port}
                listener_port   = "expose_check1"
              }
              path {
                path            = "/minio/health/ready"
                protocol        = "http"
                local_path_port = ${port}
                listener_port   = "expose_check2"
              }
            }
          }
        }
        sidecar_task {
          driver = "docker"
          resources {
            cpu    = "${cpu_proxy}"
            memory = "${memory_proxy}"
          }
        }
      }
      check {
        name      = "${service_name}-live"
        type      = "http"
        port      = "expose_check1"
        path      = "/minio/health/live"
        interval  = "10s"
        timeout   = "2s"
      }
      check {
        name      = "${service_name}-ready"
        type      = "http"
        port      = "expose_check2"
        path      = "/minio/health/ready"
        interval  = "15s"
        timeout   = "4s"
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
MINIO_ACCESS_KEY="{{ .Data.data.${vault_kv_field_access_key} }}"
MINIO_SECRET_KEY="{{ .Data.data.${vault_kv_field_secret_key} }}"
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
