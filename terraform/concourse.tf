locals {
  concourse_domain = "concourse.${local.domain_suffix}"
}

resource "random_string" "concourse_user_password" {
  length = 8
  special = false
}

data "template_file" "concourse_config" {
  template = "${file("${path.module}/templates/concourse-values.yml")}"

  vars = {
    concourse_domain = "${local.concourse_domain}"
    uaa_domain = "${local.uaa_domain}"
    user_password = "${random_string.concourse_user_password.result}"
  }
}

resource "helm_release" "concourse" {
  depends_on = [
      "module.certmanager",
      "module.externaldns"
  ]

  name       = "concourse"
  namespace  = "concourse"
  chart      = "stable/concourse"
  version    = "8.1.2"

  values = ["${data.template_file.concourse_config.rendered}"]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}