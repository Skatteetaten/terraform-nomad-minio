# Nomad
variable "nomad_provider_address" {
  type        = string
  description = "Nomad address"
  default     = "http://127.0.0.1:4646"
}
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

variable "container_environment_variables" {
  type        = list(string)
  description = "Additional minio container environment variables"
  default     = []
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