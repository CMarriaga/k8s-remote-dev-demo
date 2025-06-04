variable "identifier" {
  type        = string
  description = "Unique identifier to tag all resources created by this template"
  nullable    = false
}

variable "common_name" {
  type        = string
  description = "Common name that will be used on the \"Name\" tag"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment where the resources will be deployed"
  nullable    = false
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to assign correct tags"
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

variable "custom_tags" {
  type        = map(string)
  description = "Custom set of tags to be applied to all resources"
  default     = {}
  nullable    = false
}
