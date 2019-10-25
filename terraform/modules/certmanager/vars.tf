variable "project_id" {}

variable "cluster_endpoint" {}

variable "cluster_issuer" {
  default = "letsencrypt-prod"
}

variable "cluster_issuer_staging" {
  default = "letsencrypt-staging"
}