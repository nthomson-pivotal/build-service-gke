resource "google_service_account" "external_dns" {
  account_id   = "${var.cluster_name}-external-dns"
  display_name = "${var.cluster_name} external dns"
}

resource "google_service_account_key" "external_dns" {
  depends_on         = ["google_project_iam_member.external_dns"]
  service_account_id = "${google_service_account.external_dns.name}"
}

resource "google_project_iam_member" "external_dns" {
  project = "${var.project_id}"
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name       = "external-dns-secret"
    namespace  = "${kubernetes_namespace.external_dns.metadata.0.name}"
  }

  data = {
    "credentials.json" = "${base64decode(google_service_account_key.external_dns.private_key)}"
  }

  type = "Opaque"
}

data "template_file" "external_dns_config" {
  template = "${file("${path.module}/templates/externaldns-values.yml")}"

  vars = {
    project_id             = "${var.project_id}"
    service_account_secret = "${kubernetes_secret.external_dns.metadata.0.name}"
    dns_suffix             = "${var.dns_suffix}"
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "${kubernetes_namespace.external_dns.metadata.0.name}"
  chart      = "stable/external-dns"

  values     = ["${data.template_file.external_dns_config.rendered}"]

  provisioner "local-exec" {
    when    = "destroy"
    command = "sleep 90"
  }
}