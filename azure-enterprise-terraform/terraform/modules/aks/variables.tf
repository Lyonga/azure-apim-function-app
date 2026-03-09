variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "node_pool" {
  type = object({
    name                         = string
    vm_size                      = string
    node_count                   = number
    min_count                    = optional(number)
    max_count                    = optional(number)
    enable_auto_scaling          = optional(bool, false)
    os_disk_size_gb              = optional(number, 64)
    os_disk_type                 = optional(string, "Ephemeral")
    kubelet_disk_type            = optional(string, "OS")
    max_pods                     = optional(number, 50)
    enable_host_encryption       = optional(bool, true)
    only_critical_addons_enabled = optional(bool, true)
    type                         = optional(string, "VirtualMachineScaleSets")
    node_labels                  = optional(map(string), {})
    node_taints                  = optional(list(string), [])
    zones                        = optional(list(string))
    os_sku                       = optional(string, "Ubuntu")
  })
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "disk_encryption_set_id" {
  type    = string
  default = null
}

variable "automatic_channel_upgrade" {
  type    = string
  default = "patch"
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "local_account_disabled" {
  type    = bool
  default = true
}

variable "azure_policy_enabled" {
  type    = bool
  default = true
}

variable "role_based_access_control_enabled" {
  type    = bool
  default = true
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = true
}

variable "workload_identity_enabled" {
  type    = bool
  default = true
}

variable "image_cleaner_enabled" {
  type    = bool
  default = true
}

variable "image_cleaner_interval_hours" {
  type    = number
  default = 48
}

variable "run_command_enabled" {
  type    = bool
  default = false
}

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "key_vault_secrets_provider_enabled" {
  type    = bool
  default = true
}

variable "secret_rotation_enabled" {
  type    = bool
  default = true
}

variable "secret_rotation_interval" {
  type    = string
  default = "2m"
}

variable "load_balancer_sku" {
  type    = string
  default = "standard"
}

variable "outbound_type" {
  type    = string
  default = "loadBalancer"
}

variable "tags" {
  type    = map(string)
  default = {}
}
