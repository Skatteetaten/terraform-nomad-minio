<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>

# Terraform-nomad-minio

Terraform-nomad-minio module is IaC - infrastructure as code. Module contains a nomad job with [minio](https://min.io).
- [consul-connect](https://www.consul.io/docs/connect) integration.
- [docker driver](https://www.nomadproject.io/docs/drivers/docker.html)

## Compatibility
|Software|OSS Version|Enterprise Version|
|:--|:--|:--|
|Terraform|0.13.0 or newer||
|Consul|1.8.3 or newer|1.8.3 or newer|
|Vault|1.5.2.1 or newer|1.5.2.1 or newer|
|Nomad|0.12.3 or newer|0.12.3 or newer|

## Usage

```text
make up
```

Command will run an example with standalone instance of minio.
Minio example instance has:
- [buckets ["one", "two"]](./example/main.tf)
- [different type of files uploaded to bucket `one/`](./dev/ansible/04_upload_files.yml)

### Requirements

#### Required modules

#### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [consul](https://releases.hashicorp.com/consul/) binary available on `PATH` on the local machine.

#### Other

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_provider\_address | Nomad provider address | string | "http://127.0.0.1:4646" | yes |
| nomad\_data\_center | Nomad data centers | list(string) | ["dc1"] | yes |
| nomad\_namespace | [Enterprise] Nomad namespace | string | "default" | yes |
| service\_name | Minio service name | string | "minio" | yes |
| host | Minio host | string | "127.0.0.1" | yes |
| port | Minio port | number | 9000 | yes |
| container\_image | Minio docker image | string | "minio/minio:latest" | yes |
| access\_key | Minio access key | string | "minio" | yes |
| secret\_key | Minio secret key | string | "minio123" | yes |
| container\_environment\_variables | Additional minio container environment variables | list(string) | [] | no |
| mc\_service\_name | Minio client service name | string | "mc" | yes |
| mc\_container\_image | Minio client docker image | string | "minio/mc:latest" | yes |
| mc\_container\_environment\_variables | Additional minio client container environment variables | list(string) | [] | no |
| buckets | List of buckets to create on startup | list(string) | [] | no |


## Outputs
| Name | Description | Type |
|------|-------------|------|
| minio\_service\_name | Minio service name | string |
| minio\_access\_key | Minio access key | string |
| minio\_secret\_key | Minio secret key | string |

### Example
Example-code that shows how to use the module, and, if applicable, its different use cases.

```hcl-terraform
module "example"{
  source = "./"
}
```

### Verifying setup

You can verify successful run with next steps:

* create local proxy to minio instance with `consul` binary. Check [required software section](#required-software)

```text
make proxy
```

## Authors

## License
