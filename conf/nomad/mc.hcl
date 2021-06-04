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

    %{ if use_vault_provider && use_custom_vault_policy }
      vault {
        policies = "${vault_kv_policy_name}"
      }
    %{ endif }

      config {
        image = "${mc_container_image}"
        entrypoint = [
          "/bin/sh",
          "-c",
          "${command}"
        ]
      }
      template {
        destination = "secrets/.envs"
        change_mode = "noop"
        env = true
        data = <<EOF
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
    }
  }
}
