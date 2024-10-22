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
      tags = ["${consul_tags}"]
      port = "${port}"
      # https://docs.min.io/docs/minio-monitoring-guide.html
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
%{ if vault_secret_old_version > -1 }
{{ with secret "${vault_kv_path}?version=${vault_secret_old_version}" }}
MINIO_ACCESS_KEY_OLD="{{ .Data.data.${vault_kv_field_access_key} }}"
MINIO_SECRET_KEY_OLD="{{ .Data.data.${vault_kv_field_secret_key} }}"
{{ end }}
%{ endif }
%{ else }
MINIO_ACCESS_KEY="${access_key}"
MINIO_SECRET_KEY="${secret_key}"
%{ endif }
${ envs }
EOF
      }
  %{ if use_vault_kms }
    template {
      data = <<EOH
        {{ with secret "${vault_kms_approle_kv}" }}
          MINIO_KMS_VAULT_APPROLE_ID="{{ .Data.data.approle_id }}"
          MINIO_KMS_VAULT_APPROLE_SECRET="{{ .Data.data.secret_id }}"
          {{end}}
          MINIO_KMS_VAULT_ENDPOINT=${vault_address}
          MINIO_KMS_VAULT_KEY_NAME=${vault_kms_key_name}
          MINIO_KMS_VAULT_AUTH_TYPE=approle
          MINIO_KMS_AUTO_ENCRYPTION=on
          MINIO_KMS_VAULT_DEPRECATION=off
        EOH

        destination = "secrets/kms"
        env         = true
    }
%{endif}
      resources {
        cpu     = ${cpu}
        memory  = ${memory}
      }
    }
  }
}
