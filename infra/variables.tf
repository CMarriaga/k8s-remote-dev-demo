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
