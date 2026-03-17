# Dev Platform V2 Identity

## Purpose

This stack is the shared identity-services landing zone for the dev platform
plane.

It owns reusable managed identities, the shared platform Key Vault, the shared
customer-managed key, and the identity spoke networking that supports those
services.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- reads connectivity remote state to discover the hub VNet and shared private
  DNS zones
- reads management remote state to discover the shared Log Analytics workspace
- optionally validates its explicit `subscription_id` against the central
  subscription catalog
- creates the identity resource group
- creates the identity spoke VNet and its subnets
- links that VNet into the shared private DNS zones
- peers the identity spoke back to the hub
- creates the shared Key Vault
- creates reusable user-assigned managed identities
- creates the shared CMK used by downstream services
- assigns the Key Vault crypto role to those managed identities
- creates the Key Vault private endpoint
- sends Key Vault diagnostics to the management workspace

## What It Consumes

- `platform-v2/connectivity` remote state
  - hub VNet IDs and names
  - private DNS zone IDs and names
  - connectivity resource group name
- `platform-v2/management` remote state
  - Log Analytics workspace ID
  - management resource group name
- optional `global/subscriptions` remote state for subscription validation

## Child Modules And Resources

- `module "tags"`
- `module "resource_group"`
- `module "identity_network"`
  - creates the identity spoke VNet through the shared spoke module
- `azurerm_private_dns_zone_virtual_network_link.identity_links`
  - links the identity VNet into the shared private DNS zones
- `module "hub_to_identity_peering"`
  - peers the identity spoke to the hub
- `module "key_vault"`
  - shared private-by-default Key Vault
- `module "shared_identities"`
  - reusable user-assigned managed identities
- `module "shared_services_cmk"`
  - creates the shared customer-managed key
- `module "role_assignments"`
  - grants crypto access on the shared Key Vault
- `module "key_vault_private_endpoint"`
- `module "key_vault_diagnostics"`

## What It Serves To Other Stacks

This stack is a provider of shared identity assets.

It publishes:

- `resource_group_name`
- `vnet_id`
- `vnet_name`
- `subnet_ids`
- `shared_services_key_vault_id`
- `shared_services_key_vault_name`
- `shared_services_key_vault_uri`
- `shared_services_cmk_key_id`
- `shared_identity_names`
- `shared_identity_ids`
- `shared_identity_client_ids`
- `shared_identity_principal_ids`
- `workload_runtime_identity_id`

Primary consumer:

- `workload-v2/finserv-api`

## Code Map

- `catalog-validation.tf`: optional subscription-catalog validation
- `main.tf`: identity networking, Key Vault, identities, CMK, diagnostics
- `outputs.tf`: shared identity and key outputs
- `dev.tfvars`: naming, address space, shared identity names

## How To Extend It

- add more reusable shared identities when multiple workloads need the same
  access pattern
- publish new shared secrets, keys, or certificates through the platform
  Key Vault rather than duplicating them in workloads
- keep app-specific identities inside the workload stack unless they are truly
  shared

## Best-Practice Context

This is the right boundary for long-lived reusable identities and shared CMKs.
Keeping them in a platform identity stack makes their lifecycle independent from
any one workload and keeps RBAC cleaner.
