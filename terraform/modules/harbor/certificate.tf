data "template_file" "wildcard_cert" {
  depends_on = ["module.certmanager"]

  template = "${file("${path.module}/templates/wildcard-cert.yml")}"

  vars = {
    harbor_domain = "${local.harbor_domain}"
    notary_domain = "${local.notary_domain}"
  }
}

module "wilcard_cert" {
  source = "../apply"

  name = "harbor-cert"
  yaml = "${data.template_file.wildcard_cert.rendered}"
}