module "certmanager" {
  source = "../certmanager"

  project_id       = "${var.project_id}"
  cluster_endpoint = "${google_container_cluster.default.endpoint}"
}