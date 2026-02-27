variable "hub_vnet_id" { type = string }
variable "hub_vnet_name" { type = string }
variable "hub_rg_name" { type = string }

variable "spoke_vnet_id" { type = string }
variable "spoke_vnet_name" { type = string }
variable "spoke_rg_name" { type = string }

variable "allow_forwarded_traffic" { type = bool, default = true }
variable "allow_gateway_transit" { type = bool, default = false }
variable "use_remote_gateways" { type = bool, default = false }
