variable "vpc_id" {
  type = string
}

variable "registry_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "build_context" {
  type = string
}

variable "context_hash" {
  type = string
}

variable "build_dockerfile" {
  type = string
}

variable "container_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "service_port" {
  type = number
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "is_cdn_logging_enabled" {
  type    = bool
  default = false
}

variable "cdn_logging_bucket" {
  type    = string
  default = ""
}

variable "is_alb_logging_enabled" {
  type    = bool
  default = false
}

variable "alb_logging_bucket" {
  type    = string
  default = ""
}
