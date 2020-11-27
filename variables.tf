# Nomad
variable "nomad_datacenters" {
  type        = list(string)
  description = "Nomad data centers"
  default     = ["dc1"]
}
variable "nomad_namespace" {
  type        = string
  description = "[Enterprise] Nomad namespace"
  default     = "default"
}
variable "nomad_host_volume" {
  type        = string
  description = "Nomad Host Volume"
  default     = "persistence"
}

# Minio
variable "service_name" {
  type        = string
  description = "Minio service name"
  default     = "minio"
}

variable "host" {
  type        = string
  description = "Minio host"
  default     = "127.0.0.1"
}

variable "port" {
  type        = number
  description = "Minio port"
  default     = 9000
}

variable "cpu" {
  type        = number
  description = "CPU allocation for Minio"
  default     = 200
}

variable "memory" {
  type        = number
  description = "Memory allocation for Minio"
  default     = 1024
}

variable "container_image" {
  type        = string
  description = "Minio docker image"
  default     = "minio/minio:latest"
}

variable "access_key" {
  type        = string
  description = "Minio access key"
  default     = "minio"
}

variable "secret_key" {
  type        = string
  description = "Minio secret key"
  default     = "minio123"
}

variable "data_dir" {
  type        = string
  description = "Minio server data dir"
  default     = "/minio/data"
}

variable "container_environment_variables" {
  type        = list(string)
  description = "Additional minio container environment variables"
  default     = []
}
variable "use_host_volume" {
  type        = bool
  description = "Switch for nomad jobs to use host volume feature"
  default     = false
}

variable "use_canary" {
  type = bool
  description = "Uses canary deployment for Minio"
  default = false
}

variable "vault_secret" {
  type = object({
    use_vault_provider        = bool,
    vault_kv_policy_name      = string,
    vault_kv_path             = string,
    vault_kv_field_access_key = string,
    vault_kv_field_secret_key = string
  })
  description = "Set of properties to be able to fetch secret from vault"
  default = {
    use_vault_provider        = true
    vault_kv_policy_name      = "kv-secret"
    vault_kv_path             = "secret/data/minio"
    vault_kv_field_access_key = "access_key"
    vault_kv_field_secret_key = "secret_key"
  }
}

# MC
variable "mc_service_name" {
  type        = string
  description = "Minio client service name"
  default     = "mc"
}

variable "mc_container_image" {
  type        = string
  description = "Minio client docker image"
  default     = "minio/mc:latest"
}

variable "mc_container_environment_variables" {
  type        = list(string)
  description = "Minio client environment variables"
  default     = []
}

variable "buckets" {
  type        = list(string)
  description = "List of buckets to create on startup"
  default     = []
}

variable "minio_upstreams" {
  type = list(object({
    service_name = string,
    port         = number,
  }))
  description = "List of upstream services (list of object with service_name, port)"
  default     = []
}

variable "resource_proxy" {
  type = object({
    cpu     = number,
    memory  = number
  })
  default = {
    cpu     = 200,
    memory  = 128
  }
  description = "Minio proxy resources"
  validation {
    condition     = var.resource_proxy.cpu >= 200 && var.resource_proxy.memory >= 128
    error_message = "Proxy resource must be at least: cpu=200, memory=128."
  }
}

variable "mc_extra_commands" {
  type        = list(string)
  default     = [""]
  description = "Extra commands to run in MC container after creating buckets"
}
