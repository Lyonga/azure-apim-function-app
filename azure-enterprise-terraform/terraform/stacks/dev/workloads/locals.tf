

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
  law_name  = "law-${local.env}-${local.project}"
  appi_name = "aai-${local.name_prefix}"
  sa_name   = "st${replace(local.name_prefix, "-", "")}"
  # From global remote state
  # rg_name = try(data.terraform_remote_state.global.outputs.workload_rg_name, null)
  # workload_rg_location = try(data.terraform_remote_state.global.outputs.workload_rg_location, null)
  rg_name              = data.terraform_remote_state.global.outputs.workload_rg_name
  subnet_ids           = data.terraform_remote_state.platform.outputs.subnet_ids
  workload_rg_location = data.terraform_remote_state.global.outputs.workload_rg_location

  # From platform remote state
  # subnet_ids = try(data.terraform_remote_state.platform.outputs.subnet_ids, null)

  # Fail fast with clear messages if any required outputs are missing
  _validate = [
    local.rg_name != null ? null : (throw("global.outputs.workload_rg_name is null; apply global/resource_grouping first.")),
    local.workload_rg_location != null ? null : (throw("global.outputs.workload_rg_location is null; export it or set var.location.")),
    local.subnet_ids != null ? null : (throw("platform.outputs.subnet_ids is null; apply platform stack and export subnet_ids.")),
  ]
}