# Dev Workload V2 FinServ API

## Purpose

This stack is the application landing zone for the sample FinServ API workload.

It is the main example of how a workload stack consumes global governance and
platform-v2 shared services while still owning its workload-local resources.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- optionally validates its workload subscription against the global
  subscriptions catalog
- reads connectivity state for hub VNet and private DNS information
- reads management state for the shared Log Analytics workspace
- optionally reads identity state for shared identities and the shared CMK
- creates the workload resource group
- creates the spoke VNet and workload subnets
- peers the spoke back to the platform hub
- links the spoke to the central private DNS zones
- creates Application Insights on top of the shared workspace
- creates the workload storage account
- creates the workload Key Vault
- optionally creates App Configuration, Service Bus, SQL, ACR, Function App,
  APIM, and Azure DevOps resources
- creates private endpoints for the services that need them
- optionally creates a low-cost demo Windows VM for validating private access
  and managed identity patterns

## What It Consumes

- `platform-v2/connectivity` remote state
  - connectivity RG name
  - hub VNet ID and name
  - private DNS zone IDs and names
- `platform-v2/management` remote state
  - management RG name
  - shared Log Analytics workspace ID
- optional `platform-v2/identity` remote state
  - shared identity IDs
  - shared identity client IDs
  - shared identity principal IDs
  - shared services CMK key ID
- optional `global/subscriptions` remote state
  - subscription catalog validation

## Child Modules And Resources

Core composition:

- `module "tags"`
- `module "resource_group"`
- `module "spoke_network"`
- `module "hub_to_spoke_peering"`
- `azurerm_private_dns_zone_virtual_network_link.spoke_links`
- `azurerm_application_insights.this`
- `module "storage_account"`
- `module "key_vault"`
- `module "role_assignments"`

Optional workload services:

- `module "app_identity"`
- `module "shared_services_cmk"`
- `module "app_configuration"`
- `module "service_bus"`
- `module "sql_database"`
- `module "container_registry"`
- `module "function_app"`
- `module "api_management"`

Private connectivity helpers:

- `module "storage_private_endpoints"`
- `module "key_vault_private_endpoint"`
- `module "app_configuration_private_endpoint"`
- `module "service_bus_private_endpoint"`
- `module "sql_private_endpoint"`
- `module "function_private_endpoint"`

Validation/demo helpers:

- `terraform_data.dependency_guard`
- `terraform_data.demo_windows_vm_password_guard`
- `module "demo_windows_vm"`

## What It Serves To Other Stacks

This stack is usually the consumer edge of the platform rather than a shared
provider, but it does publish useful outputs for app delivery and operations:

- `resource_group_name`
- `subscription_id`
- `spoke_vnet_id`
- `key_vault_uri`
- `storage_account_name`
- `function_app_name`
- `app_configuration_endpoint`
- `service_bus_namespace`
- `sql_server_name`
- `api_management_name`
- effective workload identity IDs and principals
- optional demo VM details

Typical downstream consumers:

- deployment pipelines
- application configuration or deployment automation
- ad hoc validation or operator scripts

## Code Map

- `data.tf`: remote-state consumption and dependency guards
- `locals.tf`: subnet model, role-assignment maps, effective identity logic
- `main.tf`: workload composition
- `outputs.tf`: app-facing and operator-facing outputs
- `dev.tfvars`: the concrete dev landing zone configuration

## How To Extend It

- add more workload service modules behind clear feature flags
- publish any new shared dependency requirements through platform stack outputs
  instead of hardcoding platform resource IDs here
- keep shared services in platform-v2 roots and keep app-local resources here
- prefer managed identities and private endpoints over embedded secrets and
  public networking

## Best-Practice Context

This stack shows the intended v2 workload model:

- the workload owns its own RG and spoke
- shared connectivity comes from the platform connectivity plane
- shared observability comes from the management plane
- shared identities and CMKs come from the identity plane
- governance is inherited from the global layer rather than recreated here
