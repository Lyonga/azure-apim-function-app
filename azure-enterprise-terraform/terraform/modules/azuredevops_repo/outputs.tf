output "repository_id" {
  value = try(azuredevops_git_repository.this[0].id, null)
}
