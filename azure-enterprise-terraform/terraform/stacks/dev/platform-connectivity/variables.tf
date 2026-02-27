variable "prefix" { type = string, default = "org" }
variable "environment" { type = string, default = "dev" }
variable "location" { type = string, default = "eastus" }
variable "location_short" { type = string, default = "eus" }
variable "tags" { type = map(string), default = {} }

variable "hub_address_space" { type = list(string), default = ["10.0.0.0/16"] }
variable "enable_firewall" { type = bool, default = false }
variable "firewall_subnet_cidr" { type = string, default = "10.0.255.0/26" }
