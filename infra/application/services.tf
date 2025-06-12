resource "kubernetes_service" "backend" {
  metadata {
    name      = local.backend_app_name
    namespace = var.app_namespace
    labels = merge({
      app   = local.backend_app_name
      istio = "enabled"
      },
      var.app_metrics_exposed ? {
        prometheus = "scrape"
      } : {}
    )

    annotations = var.app_metrics_exposed ? {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = var.containers.backend.container_port
    } : {}
  }

  spec {
    selector = {
      app = local.backend_app_name
    }

    port {
      name        = "http"
      port        = 80
      target_port = var.containers.backend.container_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = local.frontend_app_name
    namespace = var.app_namespace
    labels = {
      app = local.frontend_app_name
    }
  }

  spec {
    selector = {
      app = local.frontend_app_name
    }

    port {
      port        = 80
      target_port = var.containers.frontend.container_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "microservice" {
  metadata {
    name      = local.microservice_app_name
    namespace = var.app_namespace
    labels = merge({
      app   = local.microservice_app_name
      istio = "enabled"
      },
      var.app_metrics_exposed ? {
        prometheus = "scrape"
      } : {}
    )

    annotations = var.app_metrics_exposed ? {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = var.containers.microservice.container_port
    } : {}
  }

  spec {
    selector = {
      app = local.microservice_app_name
    }

    port {
      name        = "http"
      port        = 80
      target_port = var.containers.microservice.container_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "rds" {
  metadata {
    name      = var.db_svc_name
    namespace = var.app_namespace
  }

  spec {
    type          = "ExternalName"
    external_name = var.rds_db_url
  }
}
