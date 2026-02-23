resource "azurerm_policy_assignment" "this" {
  name                 = var.name
  display_name         = var.display_name
  policy_definition_id = var.policy_definition_id
  scope                = var.scope
  parameters           = var.parameters == null ? null : jsonencode(var.parameters)

  metadata = jsonencode({
    deployedBy = "terraform"
  })
}
