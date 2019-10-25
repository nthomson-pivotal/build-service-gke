resource "google_compute_address" "nginx_ingress" {
  name = "${var.name}-nginx-ingress"
}

data "template_file" "nginx_config" {
  template = "${file("${path.module}/templates/values.yml")}"

  vars = {
    lb_ip = "${google_compute_address.nginx_ingress.address}"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  chart      = "stable/nginx-ingress"
  version    = "1.6.17"

  values = ["${data.template_file.nginx_config.rendered}"]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}