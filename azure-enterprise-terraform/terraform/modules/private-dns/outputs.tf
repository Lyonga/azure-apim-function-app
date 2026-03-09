output "zone_ids" {
  value = { for key, zone in azurerm_private_dns_zone.zone : key => zone.id }
}

output "zone_names" {
  value = { for key, zone in azurerm_private_dns_zone.zone : key => zone.name }
}
