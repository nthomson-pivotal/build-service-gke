variable "project_id" {}

variable "region" {
  type = "string"
}

variable "zone" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "helm_version" {
  type = "string"
  default = "v2.13.1"
}

variable "zone_name" {
  type = "string"
}