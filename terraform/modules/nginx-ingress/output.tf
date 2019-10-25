output "ip_address" {
  value = "${google_compute_address.nginx_ingress.address}"
}