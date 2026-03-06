module "workload_rg" {
  source   = "../../modules/resource_group"
  name     = local.rg_name
  location = var.workload_rg_location
  tags     = local.common_tags
}