# Google Project ID
variable "project_id" {
  type = "string"
}

# Email for certificate generation
variable "email" {
  type = "string"
}

# GKE details
variable "region" {
  type = "string"
  default = "us-central1"
}
variable "zone" {
  type = "string"
  default = "us-central1-b"
}
variable "cluster_name" {
  type = "string"
}

variable "helm_version" {
  type = "string"
  default = "v2.13.1"
}

variable "root_zone_name" {
  type = "string"
}

variable "pbs_subdomain" {

}

variable "uaa_username" {
  description = "Username of the user that will be auto-created in UAA"
}

variable "uaa_password" {
  description = "Password of the user that will be auto-created in UAA"
}