locals {
  frontend_port_name             = "${var.name}-feport"
  frontend_ip_configuration_name = "${var.name}-feip"
  backend_address_pool_name      = "${var.name}-beap"
  backend_http_settings_name     = "${var.name}-be-http"
  listener_name                  = "${var.name}-listener"
  request_routing_rule_name      = "${var.name}-rule"
}

resource "azurerm_public_ip" "this" {
  count               = var.frontend_private_ip_address == null ? 1 : 0
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  firewall_policy_id  = var.firewall_policy_id
  tags                = var.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    public_ip_address_id          = var.frontend_private_ip_address == null ? azurerm_public_ip.this[0].id : null
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address == null ? null : "Static"
    subnet_id                     = var.frontend_private_ip_address == null ? null : var.subnet_id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_ip_addresses
    fqdns        = var.backend_fqdns
  }

  backend_http_settings {
    name                                = local.backend_http_settings_name
    cookie_based_affinity               = "Disabled"
    port                                = var.backend_port
    protocol                            = var.backend_protocol
    request_timeout                     = var.request_timeout
    pick_host_name_from_backend_address = length(var.backend_fqdns) > 0
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = var.listener_protocol
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
    priority                   = var.priority
  }

  dynamic "waf_configuration" {
    for_each = var.enable_waf_configuration ? [1] : []
    content {
      enabled          = true
      firewall_mode    = var.waf_mode
      rule_set_type    = "OWASP"
      rule_set_version = var.waf_rule_set_version
    }
  }
}
