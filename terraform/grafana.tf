locals {
  grafana_domain = "grafana.${local.domain_suffix}"
}

data "template_file" "grafana_config" {
  template = "${file("${path.module}/templates/grafana-values.yml")}"

  vars = {
    grafana_domain = "${local.grafana_domain}"
    uaa_domain = "${local.uaa_domain}"
  }
}

resource "helm_release" "grafana" {
  depends_on = [
    "helm_release.prometheus", 
    "module.externaldns"
  ]

  name       = "grafana"
  namespace  = "grafana"
  chart      = "stable/grafana"
  version    = "3.8.6"

  values = ["${data.template_file.grafana_config.rendered}"]
}