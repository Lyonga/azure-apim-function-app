resource "azurerm_private_dns_zone" "zone" {
  for_each            = var.zones
  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  link_matrix = {
    for item in flatten([
      for zone_key, zone in var.zones : [
        for link_key, vnet_id in var.vnet_ids_to_link : {
          key      = "${zone_key}-${link_key}"
          zone_key = zone_key
          link_key = link_key
          vnet_id  = vnet_id
        }
      ]
    ]) : item.key => item
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = local.link_matrix
  name                  = "link-${each.value.zone_key}-${each.value.link_key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone[each.value.zone_key].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
