variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "address_space" { type = list(string) }
variable "tags" { type = map(string) }

variable "enable_firewall" { type = bool, default = false }

variable "firewall_subnet_cidr" {
  type        = string
  default     = "10.0.255.0/26"
  description = "CIDR for AzureFirewallSubnet (must be /26 or larger)."
}
