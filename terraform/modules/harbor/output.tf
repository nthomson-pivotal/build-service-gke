output "harbor_url" {
  value = "https://${local.harbor_domain}"
}

output "harbor_domain" {
  value = "${local.harbor_domain}"
}

output "harbor_admin_user" {
  value = "admin"
}

output "harbor_admin_password" {
  value = "Harbor12345"
}