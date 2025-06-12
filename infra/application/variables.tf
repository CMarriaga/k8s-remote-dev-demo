variable "common_name" {
  type     = string
  nullable = false
}

variable "app_namespace" {
  type     = string
  nullable = false
}

variable "app_service_account_name" {
  type        = string
  description = "Name of the service account that will be used by the app"
  nullable    = false
}

variable "app_service_account_role_arn" {
  type        = string
  description = "ARN of the role that will be used for the Service Account"
  nullable    = false
}

variable "app_metrics_exposed" {
  type     = bool
  default  = false
  nullable = false
}

variable "app_metrics_port" {
  type     = number
  default  = 8000
  nullable = false
}

variable "containers" {
  type = object({
    backend = object({
      image          = string
      version        = string
      container_port = number
    }),
    microservice = object({
      image          = string
      version        = string
      container_port = number
    }),
    frontend = object({
      image          = string
      version        = string
      container_port = number
    })
  })
  nullable = false
}

variable "sqs_queue_url" {
  type     = string
  nullable = false
}

variable "app_auth_db_url" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "app_env" {
  type     = map(any)
  default  = {}
  nullable = false
}

variable "db_svc_name" {
  type        = string
  default     = "rds-proxy"
  description = "Name of the RDS proxy service"
  nullable    = false
}

variable "rds_db_url" {
  type        = string
  description = "URL for the RDS database"
  nullable    = false
}
