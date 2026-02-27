resource "azurerm_key_vault" "kv" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization    = var.enable_rbac_authorization
  purge_protection_enabled     = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

output "id" { value = azurerm_key_vault.kv.id }
output "name" { value = azurerm_key_vault.kv.name }
