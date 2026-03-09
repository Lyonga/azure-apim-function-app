resource "azurerm_servicebus_namespace" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  capacity                      = var.sku == "Premium" ? var.capacity : 0
  premium_messaging_partitions  = var.sku == "Premium" ? var.premium_messaging_partitions : 0
  local_auth_enabled            = var.local_auth_enabled
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [1]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_id == null || var.customer_managed_key_identity_id == null ? [] : [1]
    content {
      key_vault_key_id                  = var.customer_managed_key_id
      identity_id                       = var.customer_managed_key_identity_id
      infrastructure_encryption_enabled = true
    }
  }
}

resource "azurerm_servicebus_queue" "this" {
  for_each     = var.queues
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id
}

resource "azurerm_servicebus_topic" "this" {
  for_each     = var.topics
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id
}
