

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

  demo_vm_role_assignments = !var.create_demo_vm || !var.enable_demo_vm_baseline_access ? {} : merge(
    {
      demo_vm_storage_blob_contributor = {
        scope                = module.storage_account.account_id
        role_definition_name = "Storage Blob Data Contributor"
        principal_id         = module.vm[0].identity_principal_id
      }
    },
    var.kv_enable_rbac ? {
      demo_vm_keyvault_reader = {
        scope                = module.keyvault.id
        role_definition_name = "Key Vault Secrets User"
        principal_id         = module.vm[0].identity_principal_id
      }
    } : {},
    {
      for name, assignment in var.demo_vm_additional_role_assignments :
      name => {
        scope                                  = assignment.scope
        role_definition_name                   = assignment.role_definition_name
        principal_id                           = coalesce(try(assignment.principal_id, null), module.vm[0].identity_principal_id)
        principal_type                         = try(assignment.principal_type, null)
        condition                              = try(assignment.condition, null)
        condition_version                      = try(assignment.condition_version, null)
        delegated_managed_identity_resource_id = try(assignment.delegated_managed_identity_resource_id, null)
        skip_service_principal_aad_check       = try(assignment.skip_service_principal_aad_check, false)
      }
    },
  )

  _validate = [
    local.rg_name != null ? null : throw("Set var.resource_group or enable global remote state before planning the legacy dev/workloads stack."),
    !var.create_demo_vm || local.app_subnet_id != null ? null : throw("Set var.app_subnet_id or enable platform remote state before creating the legacy demo VM."),
  ]
}
