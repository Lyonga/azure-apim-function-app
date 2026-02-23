resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = var.node_pool.name
    vm_size             = var.node_pool.vm_size
    node_count          = var.node_pool.node_count
    enable_auto_scaling = try(var.node_pool.enable_auto_scaling, false)
    min_count           = try(var.node_pool.min_count, null)
    max_count           = try(var.node_pool.max_count, null)
    os_disk_size_gb     = try(var.node_pool.os_disk_size_gb, 128)
    vnet_subnet_id      = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # Optional OMS agent
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [1]
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = var.tags
}
