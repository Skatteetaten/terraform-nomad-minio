variable "nomad_acl" {
  type = bool
}

variable "access_key" {
  type        = string
  description = "Minio access key"
}

variable "secret_key" {
  type        = string
  description = "Minio secret key"
}