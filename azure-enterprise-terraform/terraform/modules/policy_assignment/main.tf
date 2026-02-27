# resource "azurerm_resource_policy_assignment" "this" {
#   name                 = var.name
#   display_name         = var.display_name
#   policy_definition_id = var.policy_definition_id

#   # ✅ resource-group scope: pass RG ID here
#   resource_id          = var.scope

#   parameters = var.parameters == null ? null : jsonencode(var.parameters)

#   metadata = jsonencode({ deployedBy = "terraform" })
# }

resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = var.name
  display_name         = var.display_name
  policy_definition_id = var.policy_definition_id
  resource_group_id    = var.scope   # RG ID is valid here
  parameters           = var.parameters == null ? null : jsonencode(var.parameters)
}