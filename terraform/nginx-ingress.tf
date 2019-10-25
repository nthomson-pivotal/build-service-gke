module "nginx_ingress" {
  source = "modules/nginx-ingress"

  name = "pbs"
}