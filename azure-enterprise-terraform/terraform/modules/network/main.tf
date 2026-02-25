locals {
  # Flatten subnet->rules into a map keyed by "subnetName-ruleName"
  nsg_rules = merge([
    for subnet_name, subnet in var.subnets : {
      for r in try(subnet.nsg_rules, []) :
      "${subnet_name}-${r.name}" => merge(r, { subnet_name = subnet_name })
    }
  ]...)
}
resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Create NSGs only for subnets that have rules
resource "azurerm_network_security_group" "this" {
  for_each            = { for k, v in var.subnets : k => v if length(try(v.nsg_rules, [])) > 0 }
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
  access                       = each.value.access
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

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = { for k, v in var.subnets : k => v if length(try(v.nsg_rules, [])) > 0 }
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
