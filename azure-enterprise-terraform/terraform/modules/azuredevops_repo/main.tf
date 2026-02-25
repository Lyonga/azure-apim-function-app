# This module is OFF by default to keep the project deployable even if you don't use Azure DevOps.
# If enabled, configure the azuredevops provider in the stack's provider.tf.

data "azuredevops_project" "this" {
  count = var.enable ? 1 : 0
  name  = var.project_name
}

resource "azuredevops_git_repository" "this" {
  count      = var.enable ? 1 : 0
  project_id = data.azuredevops_project.this[0].id
  name       = var.repository_name

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository_default_branch" "this" {
  count         = var.enable ? 1 : 0
  repository_id = azuredevops_git_repository.this[0].id
  branch_name   = var.default_branch
}

# Example policy: minimum reviewers (simple and common).
resource "azuredevops_branch_policy_min_reviewers" "min_reviewers" {
  count      = var.enable && var.enable_min_reviewers_policy ? 1 : 0
  project_id = data.azuredevops_project.this[0].id
  enabled    = true
  blocking   = true

  settings {
    reviewer_count = var.min_reviewer_count

    scope {
      repository_id  = azuredevops_git_repository.this[0].id
      repository_ref = var.branch_name
      match_type     = "Exact"
    }
  }
}
