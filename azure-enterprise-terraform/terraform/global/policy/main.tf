
module "policy_assignment" {
  source = "../../modules/policy_assignment"

  name                 = var.name
  display_name         = var.display_name
  policy_definition_id = var.policy_definition_id
  scope                = var.resource_group_id
  parameters           = var.parameters
  # if your child module supports tags, pass tags = local.tags_common
}
