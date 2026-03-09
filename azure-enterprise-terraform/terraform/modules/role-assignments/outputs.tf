output "assignment_ids" {
  value       = { for key, assignment in azurerm_role_assignment.this : key => assignment.id }
  description = "Role assignment ids keyed by assignment alias."
}
