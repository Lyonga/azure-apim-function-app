data "terraform_remote_state" "platform" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.platform_state_rg
    storage_account_name = var.platform_state_sa
    container_name       = var.platform_state_container
    key                  = var.platform_state_key
  }
}

locals {
  rg_name   = data.terraform_remote_state.platform.outputs.resource_group_name
  subnet_ids = data.terraform_remote_state.platform.outputs.subnet_ids
}

# Demo VM (in app subnet)
module "vm" {
  count               = var.create_demo_vm ? 1 : 0
  source              = "../../../modules/vm_linux"
  name                = var.vm_name
  resource_group_name = local.rg_name
  location            = var.location
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  os_disk_size_gb     = var.os_disk_size_gb
  subnet_id           = local.subnet_ids["app"]
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}

# Demo Public IP + Load Balancer (to learn Azure LB building blocks)
module "pip" {
  count               = var.create_demo_lb ? 1 : 0
  source              = "../../../modules/public_ip"
  name                = "pip-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  allocation_method   = var.allocation_method
  sku                 = var.sku
  location            = var.location
  tags                = local.common_tags
}

module "lb" {
  count               = var.create_demo_lb ? 1 : 0
  source              = "../../../modules/load_balancer"
  name                = "lb-${var.environment}-${var.project_name}"
  resource_group_name = local.rg_name
  location            = var.location
  backend_pool_name   = var.backend_pool_name
  frontend_name       = var.frontend_name
  public_ip_id        = module.pip[0].id
  tags                = local.common_tags
}
