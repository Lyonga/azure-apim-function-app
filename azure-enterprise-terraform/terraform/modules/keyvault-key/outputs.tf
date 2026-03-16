locals {
  key_id = coalesce(
    try(azapi_resource.this.output.key.kid, null),
    try(azapi_resource.this.output.properties.keyUriWithVersion, null),
    try(azapi_resource.this.output.keyUriWithVersion, null),
    "${trimsuffix(var.key_vault_uri, "/")}/keys/${var.name}"
  )
}

output "id" {
  value = local.key_id
}

output "resource_id" {
  value = azapi_resource.this.id
}
