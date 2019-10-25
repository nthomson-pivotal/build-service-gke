output "uaa_url" {
  value = "https://${local.uaa_domain}"
}

output "uaa_admin_client_id" {
  value = "admin"
}

output "uaa_admin_client_secret" {
  value = "${random_string.UAA_ADMIN_CLIENT_SECRET.result}"
}

output "harbor_url" {
  value = "${module.harbor.harbor_url}"
}

output "harbor_domain" {
  value = "${module.harbor.harbor_domain}"
}

output "harbor_admin_user" {
  value = "${module.harbor.harbor_admin_user}"
}

output "harbor_admin_password" {
  value = "${module.harbor.harbor_admin_password}"
}

output "pbs_domain" {
  value = "${local.pbs_domain}"
}

output "spinnaker_url" {
  value = "https://${local.spinnaker_domain}"
}

output "concourse_url" {
  value = "https://${local.concourse_domain}"
}

output "concourse_user" {
  value = "test"
}

output "concourse_password" {
  value = "${random_string.concourse_user_password.result}"
}

output "prometheus_url" {
  value = "https://${local.prometheus_domain}"
}

output "grafana_url" {
  value = "https://${local.grafana_domain}"
}