module "harbor" {
  source = "modules/harbor"

  project_id   = "${var.project_id}"

  cluster_name = "${var.cluster_name}-harbor"
  region       = "${var.region}"
  zone         = "${var.zone}"

  zone_name    = "${google_dns_managed_zone.pbs_zone.name}"
}