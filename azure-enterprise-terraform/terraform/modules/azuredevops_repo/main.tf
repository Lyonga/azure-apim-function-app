terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
    }
  }
}

resource "azuredevops_project" "this" {
  count              = var.enable && var.create_project ? 1 : 0
  name               = var.project_name
  visibility         = var.project_visibility
  version_control    = "Git"
  work_item_template = "Agile"
}

data "azuredevops_project" "existing" {
  count = var.enable && !var.create_project ? 1 : 0
  name  = var.project_name
}

locals {
  project_id = var.enable ? coalesce(
    try(azuredevops_project.this[0].id, null),
    try(data.azuredevops_project.existing[0].id, null),
  ) : null
}

#checkov:skip=CKV2_ADO_1: The min-reviewers policy is enforced by azuredevops_branch_policy_min_reviewers, but the graph rule does not resolve settings.scope.repository_id.
resource "azuredevops_git_repository" "this" {
  count      = var.enable ? 1 : 0
  project_id = local.project_id
  name       = var.repository_name

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_branch_policy_min_reviewers" "min_reviewers" {
  count      = var.enable && var.enable_min_reviewers_policy ? 1 : 0
  project_id = local.project_id
  enabled    = true
  blocking   = true

  settings {
    reviewer_count = var.min_reviewer_count

    scope {
      repository_id  = azuredevops_git_repository.this[0].id
      repository_ref = var.default_branch
      match_type     = "Exact"
    }
  }
}
