locals {
  nsg_rules = merge([
    for subnet_name, subnet in var.subnets : {
      for rule in try(subnet.nsg_rules, []) :
      "${subnet_name}-${rule.name}" => merge(rule, { subnet_name = subnet_name })
    }
  ]...)
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id == null ? [] : [1]
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each            = { for key, subnet in var.subnets : key => subnet if length(try(subnet.nsg_rules, [])) > 0 }
  name                = "${var.name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.nsg_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = try(each.value.source_port_range, "*")
  destination_port_range      = try(each.value.destination_port_range, "*")
  source_address_prefix       = try(each.value.source_address_prefix, "*")
  destination_address_prefix  = try(each.value.destination_address_prefix, "*")
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_name].name
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = try(each.value.service_endpoints, [])
  private_endpoint_network_policies = try(
    each.value.private_endpoint_network_policies,
    try(each.value.private_endpoint_network_policies_enabled, true) ? "Enabled" : "Disabled"
  )
  enforce_private_link_service_network_policies = try(
    each.value.enforce_private_link_service_network_policies,
    try(each.value.private_link_service_network_policies_enabled, true)
  )

  dynamic "delegation" {
    for_each = try(each.value.delegations, [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = { for key, subnet in var.subnets : key => subnet if length(try(subnet.nsg_rules, [])) > 0 }
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = {
    for key, subnet in var.subnets : key => subnet if try(subnet.route_table_id, null) != null
  }
  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value.route_table_id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = {
    for key, subnet in var.subnets : key => subnet if try(subnet.nat_gateway_id, null) != null
  }
  subnet_id      = azurerm_subnet.this[each.key].id
  nat_gateway_id = each.value.nat_gateway_id
}
