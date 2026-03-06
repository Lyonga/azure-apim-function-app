variable "create_resource_group" {
  type    = bool
  default = true
}

variable "workload_rg_location" {
  description = "The location where resources will be deployed."
  type        = string
  default     = null
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "azure-enterprise-lab"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "cost_center" {
  type    = string
  default = "cc-0001"
}