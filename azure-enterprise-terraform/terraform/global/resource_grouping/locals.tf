locals {

  rg_name = "rg-${var.environment}-${var.project_name}-wkl"
  common_tags = {
    environment = var.environment
    project     = var.project_name
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
  }
}