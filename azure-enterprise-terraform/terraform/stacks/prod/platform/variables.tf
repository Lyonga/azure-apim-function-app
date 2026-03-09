variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "create_resource_group" {
  type    = bool
  default = true
}

variable "resource_group_name" {
  type    = string
  default = "rg-prod-platform"
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

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}
variable "subnets" {
  type = map(any)
  default = {
    aks = { address_prefixes = ["10.20.1.0/24"], nsg_rules = [] }
    app = { address_prefixes = ["10.20.2.0/24"], nsg_rules = [] }
  }
}

variable "aks_node_pool" {
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
  default = {
    name                         = "sys"
    vm_size                      = "Standard_D4ds_v5"
    node_count                   = 3
    enable_auto_scaling          = true
    min_count                    = 3
    max_count                    = 10
    os_disk_size_gb              = 64
    os_disk_type                 = "Ephemeral"
    kubelet_disk_type            = "OS"
    max_pods                     = 50
    enable_host_encryption       = true
    only_critical_addons_enabled = true
    type                         = "VirtualMachineScaleSets"
  }
}

variable "aks_disk_encryption_set_id" {
  type    = string
  default = null
}

variable "aks_private_dns_zone_id" {
  type    = string
  default = null
}

variable "aks_api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "aks_automatic_channel_upgrade" {
  type    = string
  default = "patch"
}

variable "aks_outbound_type" {
  type    = string
  default = "loadBalancer"
}

variable "storage_account_name" {
  type    = string
  default = "stprodlab001"
}

variable "acr_name" {
  type    = string
  default = "acrprodlab001"
}

variable "acr_georeplication_locations" {
  type    = list(string)
  default = ["centralus"]
}

variable "keyvault_name" {
  type    = string
  default = "kv-prod-lab-001"
}

variable "use_existing_subscription" {
  type    = bool
  default = true
}
