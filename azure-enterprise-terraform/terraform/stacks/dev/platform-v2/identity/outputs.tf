output "subscription_id" {
  value = var.subscription_id
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.identity_network.vnet_id
}

output "vnet_name" {
  value = module.identity_network.vnet_name
}

output "subnet_ids" {
  value = module.identity_network.subnet_ids
}

output "shared_services_key_vault_id" {
  value = module.key_vault.id
}

output "shared_services_key_vault_name" {
  value = module.key_vault.name
}

output "shared_services_key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "shared_services_cmk_key_id" {
  value = module.shared_services_cmk.id
}

output "shared_identity_names" {
  value = {
    for identity_key, identity_name in var.shared_identity_names :
    identity_key => identity_name
  }
}

output "shared_identity_ids" {
  value = {
    for identity_key, identity in module.shared_identities :
    identity_key => identity.id
  }
}

output "shared_identity_client_ids" {
  value = {
    for identity_key, identity in module.shared_identities :
    identity_key => identity.client_id
  }
}

output "shared_identity_principal_ids" {
  value = {
    for identity_key, identity in module.shared_identities :
    identity_key => identity.principal_id
  }
}

output "workload_runtime_identity_id" {
  value = try(module.shared_identities["workload_runtime"].id, null)
}
