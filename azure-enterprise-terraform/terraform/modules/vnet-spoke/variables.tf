variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "address_space" { type = list(string) }
variable "tags" { type = map(string) }

variable "subnet_workload_cidr" { type = string, default = "10.10.10.0/24" }
variable "subnet_private_endpoints_cidr" { type = string, default = "10.10.20.0/24" }
