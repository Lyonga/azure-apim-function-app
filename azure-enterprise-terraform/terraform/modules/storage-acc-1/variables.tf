variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

variable "replication" { type = string, default = "ZRS" }
variable "public_network_access_enabled" { type = bool, default = false }
