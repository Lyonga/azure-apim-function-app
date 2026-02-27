resource "azurerm_virtual_network" "hub" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

# Recommended hub subnets
resource "azurerm_subnet" "shared" {
  name                 = "snet-shared"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.20.0/24"]
  private_endpoint_network_policies_enabled = false
}

# Optional Azure Firewall
resource "azurerm_subnet" "firewall" {
  count                = var.enable_firewall ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_public_ip" "fw_pip" {
  count               = var.enable_firewall ? 1 : 0
  name                = "pip-fw"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "fw" {
  count               = var.enable_firewall ? 1 : 0
  name                = "fw-hub"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.fw_pip[0].id
  }
}

output "vnet_id" { value = azurerm_virtual_network.hub.id }
output "vnet_name" { value = azurerm_virtual_network.hub.name }
output "shared_subnet_id" { value = azurerm_subnet.shared.id }
output "private_endpoints_subnet_id" { value = azurerm_subnet.private_endpoints.id }
output "firewall_private_ip" {
  value       = var.enable_firewall ? azurerm_firewall.fw[0].ip_configuration[0].private_ip_address : null
  description = "Firewall private IP for route tables if enabled."
}
