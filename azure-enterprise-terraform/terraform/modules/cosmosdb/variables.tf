variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "kind" {
  type    = string
  default = "GlobalDocumentDB"
}

variable "failover_locations" {
  type = list(string)
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "is_virtual_network_filter_enabled" {
  type    = bool
  default = false
}

variable "consistency_level" {
  type    = string
  default = "Session"
}

variable "max_interval_in_seconds" {
  type    = number
  default = 300
}

variable "max_staleness_prefix" {
  type    = number
  default = 100000
}

variable "backup_type" {
  type    = string
  default = "Continuous"
}

variable "continuous_backup_tier" {
  type    = string
  default = "Continuous7Days"
}

variable "backup_interval_in_minutes" {
  type    = number
  default = 240
}

variable "backup_retention_in_hours" {
  type    = number
  default = 8
}

variable "backup_storage_redundancy" {
  type    = string
  default = "Geo"
}

variable "tags" {
  type    = map(string)
  default = {}
}
