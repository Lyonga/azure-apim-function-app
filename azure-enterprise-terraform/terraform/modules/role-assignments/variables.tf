variable "assignments" {
  type = map(object({
    scope                                  = string
    role_definition_name                   = string
    principal_id                           = string
    principal_type                         = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  description = "Role assignments keyed by logical name."
  default     = {}
}
