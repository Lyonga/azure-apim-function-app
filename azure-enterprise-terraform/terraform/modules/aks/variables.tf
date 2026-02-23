variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

variable "dns_prefix" { type = string }
variable "subnet_id" { type = string }

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "node_pool" {
  type = object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = optional(number)
    max_count           = optional(number)
    enable_auto_scaling = optional(bool, false)
    os_disk_size_gb     = optional(number, 128)
  })
}

variable "log_analytics_workspace_id" { type = string default = null }
variable "tags" { type = map(string) default = {} }
