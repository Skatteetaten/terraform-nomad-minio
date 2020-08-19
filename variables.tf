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

variable "minio_service_name" {
  type        = string
  description = "Minio service name"
  default     = "minio"
}

variable "minio_host" {
  type        = string
  description = "Minio host"
  default     = "127.0.0.1"
}

variable "minio_port" {
  type        = number
  description = "Minio port"
  default     = 9000
}

variable "minio_container_image" {
  type        = string
  description = "Minio server image"
  default     = "minio/minio:latest"
}

variable "mc_container_image" {
  type        = string
  description = "Minio client image"
  default     = "minio/mc:latest"
}

variable "minio_container_port" {
  type        = number
  description = "Minio server listening port"
  default     = 9000
}

variable "minio_access_key" {
  type        = string
  description = "Minio access key"
  default     = "minio"
}

variable "minio_secret_key" {
  type        = string
  description = "Minio secret key"
  default     = "minio123"
}

variable "minio_buckets" {
  type        = list(string)
  description = "List of buckets to create on startup"
  default     = ["bucket-1", "bucket-2"]
}

variable "minio_container_environment_variables" {
  type        = list(string)
  description = "Minio server environment variables"
  default     = []
}
