resource "vault_policy" "minio_kms" {
  name = "minio_kms"
  policy = <<EOH
  path "transit/datakey/plaintext/minio" {
    capabilities = ["read", "update"]
  }

  path "transit/decrypt/minio" {
    capabilities = ["read", "update"]
  }

  path "transit/rewrap/minio" {
    capabilities = ["update"]
  }

  path "transit/keys/minio" {
    capabilities = ["create", "update", "delete"]
  }
EOH
}

resource "vault_approle_auth_backend_role" "minio_kms" {
  role_name = "minio_kms"
  token_policies = [
    vault_policy.minio_kms.name
  ]
}
resource "vault_approle_auth_backend_role_secret_id" "minio_kms" {
  role_name = vault_approle_auth_backend_role.minio_kms.role_name
}