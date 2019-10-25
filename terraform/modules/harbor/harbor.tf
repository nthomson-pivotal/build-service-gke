resource "helm_repository" "harbor" {
  name = "harbor"
  url = "https://helm.goharbor.io"
}

resource "kubernetes_namespace" "harbor" {
  depends_on  = ["module.nginx_ingress"]

  metadata {
    name = "harbor"
  }
}

locals {
  harbor_domain = "harbor.${local.domain_suffix}"
  notary_domain = "notary.${local.domain_suffix}"
}

data "template_file" "harbor_config" {
  template = "${file("${path.module}/templates/harbor-values.yml")}"

  vars = {
    harbor_domain = "${local.harbor_domain}"
    notary_domain = "${local.notary_domain}"
  }
}

resource "helm_release" "harbor" {
  depends_on = [
    "module.wilcard_cert",
    "module.externaldns",
  ]

  name       = "harbor"
  namespace  = "${kubernetes_namespace.harbor.metadata.0.name}"
  repository = "${helm_repository.harbor.name}"
  chart      = "harbor"

  values = ["${data.template_file.harbor_config.rendered}"]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

