
data "template_file" "wildcard_cert" {
  depends_on = ["module.certmanager"]

  template = "${file("${path.module}/templates/wildcard-cert.yml")}"

  vars = {
    dns_suffix = "${local.domain_suffix}"
  }
}

module "wilcard_cert" {
  source = "modules/apply"

  name = "wildcard-cert"
  yaml = "${data.template_file.wildcard_cert.rendered}"
}