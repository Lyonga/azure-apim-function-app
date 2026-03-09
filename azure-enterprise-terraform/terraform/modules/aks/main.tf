resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = "Standard"
  automatic_channel_upgrade         = var.automatic_channel_upgrade
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = var.private_dns_zone_id
  public_network_access_enabled     = var.public_network_access_enabled
  local_account_disabled            = var.local_account_disabled
  azure_policy_enabled              = var.azure_policy_enabled
  role_based_access_control_enabled = var.role_based_access_control_enabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled
  workload_identity_enabled         = var.workload_identity_enabled
  image_cleaner_enabled             = var.image_cleaner_enabled
  image_cleaner_interval_hours      = var.image_cleaner_interval_hours
  run_command_enabled               = var.run_command_enabled
  disk_encryption_set_id            = var.disk_encryption_set_id

  default_node_pool {
    name                         = var.node_pool.name
    vm_size                      = var.node_pool.vm_size
    node_count                   = var.node_pool.node_count
    enable_auto_scaling          = try(var.node_pool.enable_auto_scaling, false)
    min_count                    = try(var.node_pool.min_count, null)
    max_count                    = try(var.node_pool.max_count, null)
    os_disk_size_gb              = try(var.node_pool.os_disk_size_gb, 64)
    os_disk_type                 = "Ephemeral"
    kubelet_disk_type            = try(var.node_pool.kubelet_disk_type, "OS")
    max_pods                     = try(var.node_pool.max_pods, 50)
    enable_host_encryption       = try(var.node_pool.enable_host_encryption, true)
    only_critical_addons_enabled = try(var.node_pool.only_critical_addons_enabled, true)
    type                         = try(var.node_pool.type, "VirtualMachineScaleSets")
    node_labels                  = try(var.node_pool.node_labels, {})
    node_taints                  = try(var.node_pool.node_taints, [])
    zones                        = try(var.node_pool.zones, null)
    os_sku                       = try(var.node_pool.os_sku, "Ubuntu")
    vnet_subnet_id               = var.subnet_id
    tags                         = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_authorized_ip_ranges) == 0 ? [] : [1]
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  # Optional OMS agent
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id == null ? [] : [1]
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []
    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = var.load_balancer_sku
    outbound_type     = var.outbound_type
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.private_cluster_enabled || !var.public_network_access_enabled
      error_message = "private_cluster_enabled should not be combined with public_network_access_enabled = true for this enterprise baseline."
    }

    precondition {
      condition     = try(var.node_pool.max_pods, 50) >= 50
      error_message = "node_pool.max_pods must be at least 50 to meet the baseline."
    }
  }
}
