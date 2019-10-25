locals {
  prometheus_domain = "prometheus.${local.domain_suffix}"
}

data "template_file" "prometheus_config" {
  template = "${file("${path.module}/templates/prometheus-values.yml")}"

  vars = {
    prometheus_domain = "${local.prometheus_domain}"
  }
}

resource "helm_release" "prometheus" {
  depends_on = [
    "module.certmanager", 
    "module.externaldns"
  ]

  name       = "prometheus"
  namespace  = "prometheus"
  chart      = "stable/prometheus"
  version    = "9.1.0"

  values = ["${data.template_file.prometheus_config.rendered}"]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "kubernetes_deployment" "prometheus_oauth_proxy" {
  depends_on = [
    "helm_release.prometheus"
  ]

  metadata {
    name = "oauth-proxy"
    namespace = "prometheus"

    labels = {
      app = "oauth-proxy"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "oauth-proxy"
      }
    }

    template {
      metadata {
        labels = {
          app = "oauth-proxy"
        }
      }

      spec {
        container {
          image = "quay.io/pusher/oauth2_proxy:v3.2.0"
          image_pull_policy = "Always"
          name  = "proxy"

          port {
            container_port = 4180
          }

          env = [{
              name = "OAUTH2_PROXY_PROVIDER"
              value = "oidc"
            },
            {
              name = "OAUTH2_PROXY_OIDC_ISSUER_URL"
              value = "https://${local.uaa_domain}:443/oauth/token"
            },
            {
              name = "OAUTH2_PROXY_REDIRECT_URL"
              value = "https://${local.prometheus_domain}/oauth2/callback"
            },
            {
              name = "OAUTH2_PROXY_CLIENT_ID"
              value = "prometheus-client"
            },
            {
              name = "OAUTH2_PROXY_CLIENT_SECRET"
              value = "abcd1234"
            },
            {
              name = "OAUTH2_PROXY_COOKIE_SECRET"
              value = "anyrandomstring"
            },
            {
              name = "OAUTH2_PROXY_HTTP_ADDRESS"
              value = "0.0.0.0:4180"
            },
            {
              name = "OAUTH2_PROXY_UPSTREAM"
              value = "https://${local.prometheus_domain}"
            },
            {
              name = "OAUTH2_PROXY_EMAIL_DOMAINS"
              value = "*"
            },
            {
              name = "OAUTH2_PROXY_SCOPE"
              value = "openid,roles,uaa.user"
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus_oauth_proxy" {
  metadata {
    name = "oauth-proxy"
    namespace = "prometheus"
  }

  spec {
    selector = {
      app = "${kubernetes_deployment.prometheus_oauth_proxy.metadata.0.name}"
    }
    port {
      port        = 4180
      target_port = 4180
      protocol    = "TCP"
      name        = "http"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "prometheus_oauth_proxy" {
  metadata {
    name = "oauth-proxy-ingress"
    namespace = "prometheus"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "${local.prometheus_domain}"
      http {
        path {
          backend {
            service_name = "${kubernetes_service.prometheus_oauth_proxy.metadata.0.name}"
            service_port = 4180
          }

          path = "/oauth2"
        }
      }
    }

    tls {
      hosts = ["${local.prometheus_domain}"]
      secret_name = "oauth-proxy-tls-secret"
    }
  }
}