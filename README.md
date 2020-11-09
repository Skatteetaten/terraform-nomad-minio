<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>

## Content
1. [Terraform-nomad-minio](#terraform-nomad-minio)
2. [Compatibility](#compatibility)
3. [Requirements](#requirements)
    1. [Required modules](#required-modules)
    2. [Required software](#required-software)
4. [Usage](#usage)
    1. [Verifying setup](#verifying-setup)
    2. [Intentions](#intentions)
    3. [Providers](#providers)
5. [Example usage](#example-usage)
6. [Inputs](#inputs)
7. [Outputs](#outputs)
8. [Secrets & Credentials](#secrets--credentials)
    1.[Set credentials manually](#set-credentials-manually)
    2.[Set credentials using Vault secrets](#set-credentials-using-vault-secrets)
9. [Volumes](#volumes)
10. [Contributors](#contributors)
11. [Licence](#license)


# Terraform-nomad-minio
Terraform-nomad-minio module is IaC - infrastructure as code. Module contains a nomad job with [Minio](https://min.io).
- [consul-connect](https://www.consul.io/docs/connect) integration.
- [docker driver](https://www.nomadproject.io/docs/drivers/docker.html)

## Compatibility
| Software | OSS Version | Enterprise Version |
| :------- | :---------- | :-------- |
| Terraform | 0.13.0 or newer|  |
| Consul | 1.8.3 or newer | 1.8.3 or newer |
| Vault | 1.5.2.1 or newer | 1.5.2.1 or newer |
| Nomad | 0.12.3 or newer | 0.12.3 or newer |

## Requirements

### Required modules
No modules required.

### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [Consul](https://releases.hashicorp.com/consul/) binary available on `PATH` on the local machine.

## Usage
The following command will run an example with standalone instance of Minio.
```text
make up
```

Minio example instance has:
- [buckets ["one", "two"]](example/minio_standalone/main.tf)
- [different type of files uploaded to bucket `one/`](./dev/ansible/04_upload_files.yml)

### Verifying setup
You can verify that Minio ran successful by checking the Minio UI.

First create a proxy to connect with the Minio service:
```text
make proxy
```

You can now visit the UI on [localhost:9000/](http://localhost:9000/).

### Intentions
Intentions are required when [consul acl is enabled and default_policy is deny](https://learn.hashicorp.com/tutorials/consul/access-control-setup-production#enable-acls-on-the-agents).
In the examples, intentions are created in the Ansible playboook [00_create_intention.yml](dev/ansible/00_create_intention.yml):

| Intention between | type |
| :---------------- | :--- |
| mc => minio | allow |
| minio-local => minio | allow |

> :warning: Note that these intentions needs to be created if you are using the module in another module and (consul acl enabled with default policy deny).

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)

## Example usage
Example-code that shows how to use the module, and, if applicable, its different use cases.

```hcl
module "minio" {
  source = "../.."

  # nomad
  nomad_datacenters               = ["dc1"]
  nomad_namespace                 = "default"
  nomad_host_volume               = "persistence"

  # minio
  service_name                    = "minio"
  host                            = "127.0.0.1"
  port                            = 9000
  memory                          = 2048
  cpu                             = 500
  container_image                 = "minio/minio:latest"
  vault_secret                    = {
                                      use_vault_provider     = false,
                                      vault_kv_policy_name   = "",
                                      vault_kv_path          = "",
                                      vault_kv_access_key    = "",
                                      vault_kv_secret_key    = ""
                                    }
  data_dir                        = "/minio/data"
  container_environment_variables = ["SOME_VAR_N1=some-value"]
  use_host_volume                 = true
  use_canary                      = true

  # minio client
  mc_service_name                 = "mc"
  mc_container_image              = "minio/mc:latest"
  buckets                         = ["one", "two"]
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_data\_center | Nomad data centers | list(string) | ["dc1"] | yes |
| nomad\_namespace | [Enterprise] Nomad namespace | string | "default" | yes |
| nomad\_host\_volume | Nomad host volume | string | "persistence" | no |
| service\_name | Minio service name | string | "minio" | yes |
| host | Minio host | string | "127.0.0.1" | yes |
| port | Minio port | number | 9000 | yes |
| memory | Memory allocation for Minio | number | 1024 | no |
| cpu | CPU allocation for Minio | number | 200 | no |
| container\_image | Minio docker image | string | "minio/minio:latest" | yes |
| access\_key | Minio access key | string | dynamically generated secrets with Vault  | yes |
| secret\_key | Minio secret key | string | dynamically generated secrets with Vault | yes |
| data\_dir | Minio server data dir | string | "/local/data" | yes |
| container\_environment\_variables | Additional Minio container environment variables | list(string) | [] | no |
| use\_host\_volume | Switch to enable or disable host volume | bool | false | no |
| mc\_service\_name | Minio client service name | string | "mc" | yes |
| mc\_container\_image | Minio client docker image | string | "minio/mc:latest" | yes |
| mc\_container\_environment\_variables | Additional Minio client container environment variables | list(string) | [] | no |
| buckets | List of buckets to create on startup | list(string) | [] | no |
| use\_canary | Minio canary deployment | bool | false | no |
| vault_secret.use_vault_provider | Set if want to access secrets from Vault | bool | true |
| vault_secret.vault_kv_policy_name | Vault policy name to read secrets | string | "kv-secret" |
| vault_secret.vault_kv_path | Path to the secret key in Vault | string | "secret/minio" |
| vault_secret.vault_kv_access_key | Secret key name in Vault kv path | string | "access_key" |
| vault_secret.vault_kv_secret_key | Secret key name in Vault kv path | string | "secret_key" |
| minio\_upstreams | List up connect upstreams | list(object) | [] | no |
| mc\_extra\_commands | Extra commands to run in MC container after creating buckets | list(string) | [] | no |


## Outputs
| Name | Description | Type |
|------|-------------|------|
| minio\_service\_name | Minio service name | string |
| minio\_access\_key | Minio access key | string |
| minio\_secret\_key | Minio secret key | string |
| minio\_port | Minio port number | number |

## Secrets & Credentials
The Minio access_key and secret_key is generated and put in `/secret/data/minio` inside Vault.

To get the access_key and secret_key from Vault you can login to the [Vault-UI](http://localhost:8200/) with token `master` and reveal the access_key and secret_key in `/secret/minio`.
Alternatively, you can ssh into the vagrant box with `vagrant ssh`, and use the vault binary to get the access_key and secret_key. See the following commands:
```sh
# get access_key
vault kv get -field='access_key' secret/minio

# get secret_key
vault kv get -field='secret_key' secret/minio
```
### Set credentials manually
To set the credentials manually you first need to tell the module to not fetch credentials from vault. To do that, set `vault_secret.use_vault_provider` to `false` (see below for example). If this is done the module will use the variables `access_key` and `secret_key` to set the Minio credentials. These will default to `minio` and `minio123` if not set by the user.  
Below is an example on how to disable the use of vault credentials, and setting your own credentials.

```hcl
module "minio" {
...
  vault_secret = {
                    use_vault_provider     = false,
                    vault_kv_path          = "",
                    vault_kv_access_key    = "",
                    vault_kv_secret_key    = ""
                 }
  access_key     = "some-user-provided-access-key"       # default 'minio'
  secret_key     = "some-user-provided-secret-key"       # default 'minio123'
```

### Set credentials using Vault secrets
By default `use_vault_provider` is set to `false`.
However, when testing using the box (e.g. `make dev`) the Minio access_key and secret_key is randomly generated and put in `secret/minio` inside Vault, from the [01_generate_secrets_vault.yml](dev/ansible/01_generate_secrets_vault.yml) playbook.
This is an independent process and will run regardless of the `vault_secret.use_vault_provider` is `false/true`.

If you want to use the automatically generated credentials in the box, you can do so by changing the `vault_secret` object as seen below:
```hcl
module "minio" {
...
  vault_secret  = {
                    use_vault_provider     = true,
                    vault_kv_policy_name   = "kv-secret"
                    vault_kv_path          = "secret/minio",
                    vault_kv_access_key    = "access_key",
                    vault_kv_secret_key    = "secret_key"
                  }
}
```

If you want to change the secrets path and keys/values in Vault with your own configuration you would need to change the variables in the `vault_secret`-object.
Say that you have put your secrets in `secret/services/minio/users` and change the keys to `alt_access_key` and `alt_secret_key`. Then you need to do the following configuration:
```hcl
module "minio" {
...
  vault_secret  = {
                    use_vault_provider     = true,
                    vault_kv_policy_name   = "kv-users-secret"
                    vault_kv_path          = "secret/services/minio/users",
                    vault_kv_access_key    = "alt_access_key",
                    vault_kv_secret_key    = "alt_secret_key"
                  }
}
```

## Volumes
We are using [host volume](https://www.nomadproject.io/docs/job-specification/volume) to store Minio data.
Minio data will now be available in the `persistence/minio` folder.

## Contributors
[<img src="https://avatars0.githubusercontent.com/u/40291976?s=64&v=4">](https://github.com/fredrikhgrelland)
[<img src="https://avatars2.githubusercontent.com/u/29984156?s=64&v=4">](https://github.com/claesgill)
[<img src="https://avatars3.githubusercontent.com/u/15572799?s=64&v=4">](https://github.com/zhenik)
[<img src="https://avatars3.githubusercontent.com/u/67954397?s=64&v=4">](https://github.com/Neha-Sinha2305)
[<img src="https://avatars3.githubusercontent.com/u/71001093?s=64&v=4">](https://github.com/dangernil)
[<img src="https://avatars1.githubusercontent.com/u/51820995?s=64&v=4">](https://github.com/pdmthorsrud)
[<img src="https://avatars3.githubusercontent.com/u/10536149?s=64&v=4">](https://github.com/oschistad)

## License
This work licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.
