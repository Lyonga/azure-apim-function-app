data "azurerm_client_config" "current" {
  
}
resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  #tenant_id                   = var.tenant_id
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  sku_name                    = var.sku_name
  purge_protection_enabled    = var.purge_protection_enabled
  soft_delete_retention_days  = var.soft_delete_retention_days
  enable_rbac_authorization   = var.enable_rbac_authorization
  # Network config: currently public
  public_network_access_enabled = true
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Example: Assign a workload identity read access to secrets only
# Replace <workload_principal_object_id>
# resource "azurerm_role_assignment" "kv_secrets_user" {
#   scope                = azurerm_key_vault.this.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id = azurerm_user_assigned_identity.app_identity.principal_id
# }