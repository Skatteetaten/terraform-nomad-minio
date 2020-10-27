<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>

## Content
1. [Terraform-nomad-minio](#terraform-nomad-minio)
2. [Compatibility](#compatibility)
3. [Requirements](#requirements)
    1. [Required modules](#required-modules)
    2. [Required software](#required-software)
    3. [Other](#other)
4. [Usage](#usage)
    1. [Providers](#providers)
    2. [Intentions](#intentions)
5. [Inputs](#inputs)
6. [Outputs](#outputs)
    1. [Example](#example)
7. [Vault secrets](#vault-secrets)
8. [Volumes](#volumes)
9. [Verifying setup](#verifying-setup)
10. [Authors](#authors)
11. [Licence](#license)


# Terraform-nomad-minio

Terraform-nomad-minio module is IaC - infrastructure as code. Module contains a nomad job with [minio](https://min.io).
- [consul-connect](https://www.consul.io/docs/connect) integration.
- [docker driver](https://www.nomadproject.io/docs/drivers/docker.html)

## Compatibility
| Software | OSS Version | Enterprise Version |
| :------- | :---------- | :-------- |
| Terraform | 0.13.0 or newer|  |
| Consul | 1.8.3 or newer | 1.8.3 or newer |
| Vault | 1.5.2.1 or newer | 1.5.2.1 or newer |
| Nomad | 0.12.3 or newer | 0.12.3 or newer |


## Usage
```text
make up
```
Command will run an example with standalone instance of minio.
Minio example instance has:
- [buckets ["one", "two"]](./example/main.tf)
- [different type of files uploaded to bucket `one/`](./dev/ansible/04_upload_files.yml)

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)

### Intentions
Intentions are required when [consul acl is enabled and default_policy is deny](https://learn.hashicorp.com/tutorials/consul/access-control-setup-production#enable-acls-on-the-agents).
In the examples, intentions are created in the Ansible playboook [00_create_intention.yml](dev/ansible/00_create_intention.yml):

| Intention between | type |
| :---------------- | :--- |
| mc => minio | allow |
| minio-local => minio | allow |

> :warning: Note that these intentions needs to be created if you are using the module in another module and (consul acl enabled with default policy deny).
>


### Requirements

#### Required modules

#### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [consul](https://releases.hashicorp.com/consul/) binary available on `PATH` on the local machine.

#### Other

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_data\_center | Nomad data centers | list(string) | ["dc1"] | yes |
| nomad\_namespace | [Enterprise] Nomad namespace | string | "default" | yes |
| nomad\_host\_volume | Nomad host volume | string | "persistence" | no |
| service\_name | Minio service name | string | "minio" | yes |
| host | Minio host | string | "127.0.0.1" | yes |
| port | Minio port | number | 9000 | yes |
| container\_image | Minio docker image | string | "minio/minio:latest" | yes |
| access\_key | Minio access key | string | dynamically generated secrets with Vault  | yes |
| secret\_key | Minio secret key | string | dynamically generated secrets with Vault | yes |
| data\_dir | Minio server data dir | string | "/local/data" | yes |
| container\_environment\_variables | Additional minio container environment variables | list(string) | [] | no |
| use\_host\_volume | Switch to enable or disable host volume | bool | false | no |
| mc\_service\_name | Minio client service name | string | "mc" | yes |
| mc\_container\_image | Minio client docker image | string | "minio/mc:latest" | yes |
| mc\_container\_environment\_variables | Additional minio client container environment variables | list(string) | [] | no |
| buckets | List of buckets to create on startup | list(string) | [] | no |
| use\_canary | Minio canary deployment | bool | false | no |


## Outputs
| Name | Description | Type |
|------|-------------|------|
| minio\_service\_name | Minio service name | string |
| minio\_access\_key | Minio access key | string |
| minio\_secret\_key | Minio secret key | string |


### Example
Example-code that shows how to use the module, and, if applicable, its different use cases.

```hcl-terraform
module "minio" {
  source = "github.com/fredrikhgrelland/terraform-nomad-minio.git?ref=0.0.3"

  # nomad
  nomad_datacenters               = ["dc1"]
  nomad_namespace                 = "default"
  nomad_host_volume               = "persistence"

  # minio
  service_name                    = "minio"
  host                            = "127.0.0.1"
  port                            = 9000
  container_image                 = "minio/minio:latest"
  data_dir                        = "/local/data"
  container_environment_variables = ["SOME_VAR_N1=some-value"]
  use_host_volume                 = false

  # minio client
  mc_service_name                 = "mc"
  mc_container_image              = "minio/mc:latest"
  buckets                         = ["one", "two"]
}
```
## Vault secrets
The minio access_key and secret_key is generated and put in `/secret/minio` inside Vault.

To get the username and password from Vault you can login to the [Vault-UI](http://localhost:8200/) with token `master` and reveal the username and password in `/secret/minio`.
Alternatively, you can ssh into the vagrant box with `vagrant ssh`, and use the vault binary to get the access_key and secret_key. See the following commands:
```sh
# get access_key
vault kv get -field='access_key' secret/minio

# get secret_key
vault kv get -field='secret_key' secret/minio
```
## Volumes
We are using [host volume](https://www.nomadproject.io/docs/job-specification/volume) to store minio data.
Minio data will now be available in the `persistence/minio` folder.


## Verifying setup

You can verify successful run with next steps:

* create local proxy to minio instance with `consul` binary. Check [required software section](#required-software)

```text
make proxy
```

## Authors

## License
This work licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.
