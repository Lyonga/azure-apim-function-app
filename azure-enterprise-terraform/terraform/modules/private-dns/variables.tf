variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

variable "zones" {
  type = map(object({
    name = string
  }))
  description = "Map of private DNS zones to create."
}

variable "vnet_ids_to_link" {
  type        = map(string)
  description = "Map of link-name => vnet_id"
}
