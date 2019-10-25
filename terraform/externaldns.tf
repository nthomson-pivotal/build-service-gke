module "externaldns" {
  source = "modules/externaldns"

  project_id       = "${var.project_id}"
  dns_suffix       = "${local.domain_suffix}"
  cluster_name     = "${var.cluster_name}"
}