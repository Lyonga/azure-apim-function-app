output "subscription_resource_id" {
  value = try(azapi_resource.subscription_alias[0].id, null)
}
