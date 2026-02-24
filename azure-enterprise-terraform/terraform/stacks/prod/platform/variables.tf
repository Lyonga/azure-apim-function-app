variable "environment" { type = string default = "prod" }
variable "location" { type = string default = "eastus2" }

variable "create_resource_group" { type = bool default = true }
variable "resource_group_name" { type = string default = "rg-prod-platform" }

variable "project_name" { type = string default = "azure-enterprise-lab" }
variable "owner" { type = string default = "platform-team" }
variable "cost_center" { type = string default = "cc-0001" }

variable "vnet_address_space" { type = list(string) default = ["10.20.0.0/16"] }
variable "subnets" {
  type = map(any)
  default = {
    aks = { address_prefixes = ["10.20.1.0/24"], nsg_rules = [] }
    app = { address_prefixes = ["10.20.2.0/24"], nsg_rules = [] }
  }
}

variable "aks_node_pool" {
  type = any
  default = {
    name                = "sys"
    vm_size             = "Standard_D4s_v5"
    node_count          = 3
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    os_disk_size_gb     = 128
  }
}

variable "storage_account_name" { type = string default = "stprodlab001" }
variable "acr_name" { type = string default = "acrprodlab001" }
variable "keyvault_name" { type = string default = "kv-prod-lab-001" }

variable "use_existing_subscription" {
  type    = bool
  default = true
}
