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

resource "azurerm_network_security_rule" "rules" {
  for_each = {
    for subnet_name, subnet in var.subnets :
    subnet_name => subnet
    if length(try(subnet.nsg_rules, [])) > 0
  }

  network_security_group_name = "<REQUIRED_VALUE>"
  access                      = "<REQUIRED_VALUE>"
  name                        = "<REQUIRED_VALUE>"
  resource_group_name         = "<REQUIRED_VALUE>"
  priority                    = "<REQUIRED_VALUE>"
  direction                   = "<REQUIRED_VALUE>"
  protocol                    = "<REQUIRED_VALUE>"

  # flatten rules
  dynamic "rule" {
    for_each = try(each.value.nsg_rules, [])
    content {
      name                       = rule.value.name
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_port_range          = rule.value.source_port_range
      destination_port_range     = rule.value.destination_port_range
      source_address_prefix      = rule.value.source_address_prefix
      destination_address_prefix = rule.value.destination_address_prefix
    }
  }

  lifecycle { ignore_changes = [rule] }
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
