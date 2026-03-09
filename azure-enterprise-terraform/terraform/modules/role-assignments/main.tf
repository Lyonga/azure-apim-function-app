resource "azurerm_role_assignment" "this" {
  for_each = var.assignments

  scope                                  = each.value.scope
  role_definition_name                   = each.value.role_definition_name
  principal_id                           = each.value.principal_id
  principal_type                         = try(each.value.principal_type, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}
