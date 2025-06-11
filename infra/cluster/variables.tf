variable "common_name" {
  type        = string
  description = "Common name that will be used on the \"Name\" tag"
  nullable    = false
}

variable "region" {
  type        = string
  description = "Common name that will be used on the \"Name\" tag"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment where the resources will be deployed"
  nullable    = false
}

variable "cidr_block" {
  type        = string
  description = "CIDR block that will be used for the whole VPC"
  nullable    = false
}

variable "public_subnets" {
  type = list(object({
    cidr       = string
    az         = string
    eks_subnet = optional(bool, false)
  }))
  description = "Definition for public subnets created for the VPC"
  nullable    = false
}

variable "private_subnets" {
  type = list(object({
    cidr       = string
    az         = string
    eks_subnet = optional(bool, false)
  }))
  description = "Definition for private subnets created for the VPC"
  nullable    = false
}

variable "rds_db_name" {
  type        = string
  description = "Name of the database when created"
  default     = "demo"
  nullable    = false
}

variable "rds_username" {
  type        = string
  description = "Username used to access the database"
  default     = "demo"
  nullable    = false
}

variable "rds_password" {
  type        = string
  description = "Password user to access the database"
  default     = "demo-local-remote"
  nullable    = false
}

variable "rds_port" {
  type        = number
  description = "Port where the database will be running"
  default     = 5432
  nullable    = false
}

variable "rds_managed_password" {
  type        = bool
  description = "Define if the password should be manages via secrets manager"
  default     = false
  nullable    = false
}

variable "app_namespace" {
  type        = string
  description = "Namespace where the main apps will be deployed"
  nullable    = false
}

variable "app_service_account_name" {
  type        = string
  description = "Name of the service account that will be used by the app"
  nullable    = false
}

variable "istio_namespace" {
  type    = string
  default = "istio-system"
}

variable "istio_version" {
  type    = string
  default = "1.22.0"
}

variable "install_ingress_gateway" {
  type    = bool
  default = true
}

variable "grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  type    = string
  default = "admin"
}
