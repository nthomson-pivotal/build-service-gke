resource "google_dns_record_set" "pbs" {
  name = "pbs.${google_dns_managed_zone.pbs_zone.dns_name}"
  managed_zone = "${google_dns_managed_zone.pbs_zone.name}"
  type = "A"
  ttl  = 30

  rrdatas = ["${module.nginx_ingress.ip_address}"]
}

locals {
  pbs_domain = "${replace(google_dns_record_set.pbs.name, "/[.]$/", "")}"
}