resource "azurerm_virtual_network" "spoke" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "workload" {
  name                 = "snet-workload"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_workload_cidr]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_private_endpoints_cidr]
  private_endpoint_network_policies_enabled = false
}

output "vnet_id" { value = azurerm_virtual_network.spoke.id }
output "vnet_name" { value = azurerm_virtual_network.spoke.name }
output "workload_subnet_id" { value = azurerm_subnet.workload.id }
output "private_endpoints_subnet_id" { value = azurerm_subnet.private_endpoints.id }
