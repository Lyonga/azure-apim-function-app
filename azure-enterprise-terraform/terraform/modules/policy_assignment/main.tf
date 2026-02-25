resource "azurerm_resource_policy_assignment" "this" {
  name                 = var.name
  display_name         = var.display_name
  policy_definition_id = var.policy_definition_id
  resource_id          = var.scope  # for resource-level assignments, this is the resource ID (e.g., RG id)

  parameters = var.parameters == null ? null : jsonencode(var.parameters)

  metadata = jsonencode({ deployedBy = "terraform" })
}