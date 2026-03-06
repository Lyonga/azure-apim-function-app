module "workload_rg" {
  source   = "../../../modules/resource_group"
  count    = var.create_resource_group ? 1 : 0
  name     = local.rg_name
  location = var.workload_rg_location
  tags     = local.common_tags
}