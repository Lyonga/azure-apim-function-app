variable "prefix" { type = string, default = "org" }
variable "environment" { type = string, default = "dev" }
variable "location" { type = string, default = "eastus" }
variable "location_short" { type = string, default = "eus" }
variable "service_name" { type = string, default = "app" }
variable "tags" { type = map(string), default = {} }

# Hub references (fill from platform-connectivity outputs)
variable "hub_vnet_id" { type = string }
variable "hub_vnet_name" { type = string }
variable "hub_rg_name" { type = string }

# Log Analytics workspace (fill from platform-management outputs)
variable "log_analytics_workspace_id" { type = string }

variable "spoke_address_space" { type = list(string), default = ["10.10.0.0/16"] }
variable "spoke_workload_subnet_cidr" { type = string, default = "10.10.10.0/24" }
variable "spoke_pe_subnet_cidr" { type = string, default = "10.10.20.0/24" }

variable "storage_replication" { type = string, default = "ZRS" }
