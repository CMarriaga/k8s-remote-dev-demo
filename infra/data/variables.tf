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

variable "vpc_id" {
  type        = string
  description = "ID of the main VPC to use"
  nullable    = false
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of the main VPC to use"
  nullable    = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of IDs for the private subnets"
  nullable    = false
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of IDs for the public subnets"
  nullable    = false
}

variable "eks_private_subnet_ids" {
  type        = list(string)
  description = "List of IDs for the private subnets for EKS cluster"
  nullable    = false
}

variable "eks_public_subnet_ids" {
  type        = list(string)
  description = "List of IDs for the public subnets for EKS cluster"
  nullable    = false
}

variable "custom_tags" {
  type        = map(string)
  description = "Custom set of tags to be applied to all resources"
  default     = {}
  nullable    = false
}
