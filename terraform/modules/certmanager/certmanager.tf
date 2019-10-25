resource "null_resource" "blocker" {
  provisioner "local-exec" {
    command = "echo ${var.cluster_endpoint}"
  }
}

resource "kubernetes_job" "certmanager_prereqs" {
  metadata {
    name = "certmanager-preqs"
    namespace = "kube-system"
  }

  spec {
    template {
      metadata {}

      spec {
        container {
          name    = "certmanager-preqs"
          image   = "lachlanevenson/k8s-kubectl:v1.13.10"
          command = ["kubectl", "apply", "-f", "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml"]
        }
        
        restart_policy = "Never"
        service_account_name = "helm"
        automount_service_account_token = true
      }
    }

    backoff_limit = 4
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "helm_repository" "jetstack" {
  name = "jetstack"
  url = "https://charts.jetstack.io"
}

resource "helm_release" "certmanager" {
  depends_on = [
    "kubernetes_job.certmanager_prereqs", 
  ]

  name       = "certmanager"
  namespace  = "certmanager"
  repository = "${helm_repository.jetstack.name}"
  chart      = "cert-manager"
  version    = "v0.8.1"

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "${var.cluster_issuer}"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name  = "ingressShim.defaultACMEChallengeType"
    value = "dns01"
  }

  set {
    name  = "ingressShim.defaultACMEDNS01ChallengeProvider"
    value = "clouddns"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

data "template_file" "cluster_issuers" {
  template = "${file("${path.module}/templates/cluster-issuers.yml")}"

  vars = {
    project_id             = "${var.project_id}"
    cluster_issuer         = "${var.cluster_issuer}"
    cluster_issuer_staging = "${var.cluster_issuer_staging}"
  }
}

module "cluster_issuers" {
  source = "../apply"

  name = "cluster-issuers"
  yaml = "${data.template_file.cluster_issuers.rendered}"
  blocker = "${helm_release.certmanager.status}"
}