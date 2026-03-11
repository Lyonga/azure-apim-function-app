output "subscription_resource_id" {
  value = try(azapi_resource.subscription_alias[0].id, null)
}

output "subscription_id" {
  value = try(jsondecode(azapi_resource.subscription_alias[0].output).properties.subscriptionId, null)
}

output "provisioning_state" {
  value = try(jsondecode(azapi_resource.subscription_alias[0].output).properties.provisioningState, null)
}
