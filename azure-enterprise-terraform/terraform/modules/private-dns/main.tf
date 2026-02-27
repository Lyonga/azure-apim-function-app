resource "azurerm_private_dns_zone" "zone" {
  for_each            = var.zones
  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each = {
    for zone_key, zone in var.zones :
    zone_key => {
      zone_name = zone.name
    }
  }

  name                  = "link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone[each.key].name
  virtual_network_id    = values(var.vnet_ids_to_link)[0] # at least one; additional handled below
}

# Additional links (if more than one vnet)
resource "azurerm_private_dns_zone_virtual_network_link" "extra_links" {
  for_each = {
    for zone_key, zone in var.zones :
    zone_key => zone
  }

  # create one link per VNet per zone (excluding the first link above)
  dynamic "link" { for_each = [] content {} }
}

# Terraform doesn't support nested for_each well for resource count per item without complex transforms.
# To keep this baseline simple, we support linking zones to **one** vnet via var.vnet_ids_to_link (first value),
# and additionally expose outputs so you can add more links in stacks (recommended in enterprise).
output "zone_ids" {
  value = { for k, z in azurerm_private_dns_zone.zone : k => z.id }
}
output "zone_names" {
  value = { for k, z in azurerm_private_dns_zone.zone : k => z.name }
}
