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
  rg_name    = data.terraform_remote_state.platform.outputs.resource_group_name
  subnet_ids = data.terraform_remote_state.platform.outputs.subnet_ids
}

module "vm" {
  count               = var.create_demo_vm ? 1 : 0
  source              = "../../../modules/vm_linux"
  name                = var.vm_name
  resource_group_name = local.rg_name
  location            = var.location
  subnet_id           = local.subnet_ids["app"]
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}
