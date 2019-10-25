data "google_container_engine_versions" "default" {
  zone = "${var.zone}"
}

data "google_client_config" "current" {}

resource "google_container_cluster" "default" {
  name = "${var.cluster_name}-main"
  zone = "${var.zone}"
  initial_node_count = 2
  min_master_version = "${data.google_container_engine_versions.default.default_cluster_version}"

  node_config {
    image_type = "UBUNTU"
    machine_type = "n1-standard-4"

    metadata {
      "disable-legacy-endpoints" = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = "destroy"
    command = "sleep 90"
  }

  provisioner "local-exec" {
    when = "create"
    command = "gcloud container clusters get-credentials ${var.cluster_name}-main --zone ${var.zone} --project ${var.project_id}"
  }
}

data "google_dns_managed_zone" "root_zone" {
  name = "${var.root_zone_name}"
}

resource "google_dns_managed_zone" "pbs_zone" {
  name        = "${var.cluster_name}"
  dns_name    = "${var.pbs_subdomain}.${data.google_dns_managed_zone.root_zone.dns_name}"
  description = "DNS zone for the PBS cluster ${var.cluster_name}"
}

resource "google_dns_record_set" "ns_record" {
  managed_zone = "${data.google_dns_managed_zone.root_zone.name}"
  name = "${var.pbs_subdomain}.${data.google_dns_managed_zone.root_zone.dns_name}"
  rrdatas = [
    "${google_dns_managed_zone.pbs_zone.name_servers}",
  ]
  ttl = 30
  type = "NS"

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

locals{
  domain_suffix = "${replace(google_dns_managed_zone.pbs_zone.dns_name, "/[.]$/", "")}"
}