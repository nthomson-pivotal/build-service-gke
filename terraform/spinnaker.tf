locals {
  spinnaker_domain = "spinnaker.${local.domain_suffix}"
  spinnaker_gate_domain = "gate.spinnaker.${local.domain_suffix}"
}

data "template_file" "spinnaker_config" {
  template = "${file("${path.module}/templates/spinnaker-values.yml")}"

  vars = {
    spinnaker_domain = "${local.spinnaker_domain}"
    spinnaker_gate_domain = "${local.spinnaker_gate_domain}"
    uaa_url = "https://${local.uaa_domain}:443"
    acme_dns_provider = "clouddns"
    gcs_service_key = "${google_service_account_key.spinnaker_gcs.private_key}"
    google_project_id = "${var.project_id}"
    bucket_name = "${google_storage_bucket.spinnaker_gcs.name}"
  }
}

resource "helm_release" "spinnaker" {
  depends_on = [
    "module.certmanager",
    "module.harbor",
    "helm_release.prometheus",
    "module.externaldns"
  ]

  name       = "spinnaker"
  namespace  = "spinnaker"
  chart      = "stable/spinnaker"
  version    = "1.13.2"

  wait       = false
  timeout    = 600

  values = ["${data.template_file.spinnaker_config.rendered}"]
}

resource "google_service_account" "spinnaker_gcs" {
  account_id   = "${var.cluster_name}-spinnaker-gcs"
  display_name = "${var.cluster_name} spinnaker gcs"
}

resource "google_service_account_key" "spinnaker_gcs" {
  depends_on         = ["google_project_iam_member.spinnaker_gcs"]
  service_account_id = "${google_service_account.spinnaker_gcs.name}"
}

resource "google_project_iam_member" "spinnaker_gcs" {
  project = "${var.project_id}"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.spinnaker_gcs.email}"
}

resource "google_storage_bucket" "spinnaker_gcs" {
  name     = "${var.cluster_name}-spinnaker-gcs"

  force_destroy = true
}