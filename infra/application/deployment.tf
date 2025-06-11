resource "kubernetes_deployment" "backend" {
  metadata {
    name      = local.backend_app_name
    namespace = var.app_namespace
    labels = {
      app     = local.backend_app_name
      version = var.containers.backend.version # Helps Kiali track versions
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.backend_app_name
      }
    }

    template {
      metadata {
        labels = {
          app     = local.backend_app_name
          version = var.containers.backend.version
        }
        annotations = merge(
          {
            "sidecar.istio.io/inject" = "true"
          },
          var.app_metrics_exposed ? {
            "prometheus.io/scrape" = "true"
            "prometheus.io/port"   = var.app_metrics_port
          } : {}
        )
      }

      spec {
        termination_grace_period_seconds = 10
        service_account_name             = var.app_service_account_name
        container {
          name  = local.backend_app_name
          image = format("%s:%s", var.containers.backend.image, var.containers.backend.version)

          port {
            container_port = var.containers.backend.container_port
          }

          dynamic "env" {
            for_each = var.app_env
            content {
              name  = env.key
              value = env.value
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "VERSION"
            value = var.containers.backend.version
          }

          env {
            name = "DB_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.backend.metadata[0].name
                key  = "db_url"
              }
            }
          }

          env {
            name = "SQS_QUEUE_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.backend.metadata[0].name
                key  = "sqs_url"
              }
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/readyz"
              port = var.containers.backend.container_port
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = var.containers.backend.container_port
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }

        container {
          name    = format("%s-debug", var.common_name)
          image   = "public.ecr.aws/aws-cli/aws-cli:latest"
          command = ["sleep", "100000"]

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "VERSION"
            value = var.containers.backend.version
          }

          env {
            name = "DB_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.backend.metadata[0].name
                key  = "db_url"
              }
            }
          }

          env {
            name = "SQS_QUEUE_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.backend.metadata[0].name
                key  = "sqs_url"
              }
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = local.frontend_app_name
    namespace = var.app_namespace
    labels = {
      app     = local.frontend_app_name
      version = var.containers.frontend.version
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.frontend_app_name
      }
    }

    template {
      metadata {
        labels = {
          app     = local.frontend_app_name
          version = var.containers.frontend.version
        }
        annotations = merge(
          {
            "sidecar.istio.io/inject" = "true"
          },
          var.app_metrics_exposed ? {
            "prometheus.io/scrape" = "true"
            # TODO: add this port into the containers variable
            "prometheus.io/port" = var.app_metrics_port
          } : {}
        )
      }

      spec {
        termination_grace_period_seconds = 10

        container {
          name  = local.frontend_app_name
          image = format("%s:%s", var.containers.frontend.image, var.containers.frontend.version)

          port {
            container_port = var.containers.frontend.container_port
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.frontend.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 2
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}
