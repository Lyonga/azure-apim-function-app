locals {
  common_tags = {
    environment = var.environment
    project     = var.project_name
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
  }
}
