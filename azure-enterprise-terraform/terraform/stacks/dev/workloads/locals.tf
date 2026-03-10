

locals {
  env         = var.environment
  project     = var.project_name
  collection  = var.collection_name
  name_prefix = lower(replace(local.collection, " ", ""))
  tags_common = merge(var.tags, {
    environment = local.env
    project     = local.project
    managed_by  = "terraform"
  })
  # Names
  law_name             = "law-${local.env}-${local.project}"
  appi_name            = "aai-${local.name_prefix}"
  sa_name              = substr("st${replace(local.name_prefix, "-", "")}", 0, 24)
  global_outputs       = var.use_global_remote_state ? try(data.terraform_remote_state.global[0].outputs, {}) : {}
  platform_outputs     = var.use_platform_remote_state ? try(data.terraform_remote_state.platform[0].outputs, {}) : {}
  rg_name              = try(local.global_outputs.workload_rg_name, var.resource_group, null)
  workload_rg_location = try(local.global_outputs.workload_rg_location, var.location)
  subnet_ids           = try(local.platform_outputs.subnet_ids, {})
  app_subnet_id        = try(local.subnet_ids["app"], var.app_subnet_id, null)

  _validate = [
    local.rg_name != null ? null : throw("Set var.resource_group or enable global remote state before planning the legacy dev/workloads stack."),
    !var.create_demo_vm || local.app_subnet_id != null ? null : throw("Set var.app_subnet_id or enable platform remote state before creating the legacy demo VM."),
  ]
}
