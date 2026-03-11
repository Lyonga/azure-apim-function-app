output "resource_group_name" {
  value = module.resource_group.name
}

output "subscription_id" {
  value = var.subscription_id
}

output "hub_vnet_id" {
  value = module.hub_network.vnet_id
}

output "hub_vnet_name" {
  value = module.hub_network.vnet_name
}

output "hub_subnet_ids" {
  value = module.hub_network.subnet_ids
}

output "firewall_private_ip" {
  value = module.hub_network.firewall_private_ip
}

output "private_dns_zone_ids" {
  value = module.private_dns.zone_ids
}

output "private_dns_zone_names" {
  value = module.private_dns.zone_names
}
