variable "name"                 { type = string }
variable "display_name"         { type = string }
variable "policy_definition_id" { type = string }
variable "resource_group_id"    { type = string }    # scope
variable "parameters"           { type = any default = null }
variable "tags"                 { type = map(string) default = {} }