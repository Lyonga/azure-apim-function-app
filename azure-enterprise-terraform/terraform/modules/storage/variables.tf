variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

variable "account_tier" {
  type    = string
  default = "Standard"
}
variable "account_replication_type" { type = string default = "LRS" }
variable "account_kind" { type = string default = "StorageV2" }
variable "min_tls_version" { type = string default = "TLS1_2" }
variable "allow_blob_public_access" { type = bool default = false }

variable "containers" {
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

variable "tags" { type = map(string) default = {} }
