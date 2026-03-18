# Dev Workload V2 FinServ API

## Purpose

This stack is the reference workload landing zone for the `finserv-api`
application.

It shows how a workload should consume global governance and shared platform
services while still owning its own workload-local resources.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- Workload teams need a clear example of how to build a new landing zone on top
  of the platform pattern.
- Applications should own their own resource group, spoke network, and
  workload-local services.
- Shared services such as hub connectivity, monitoring, and shared identities
  should be consumed, not recreated.

## What This Stack Owns

- the workload resource group
- the workload spoke VNet and subnets
- workload-local NSGs and peering
- workload-local application services such as storage, Key Vault, and optional
  service modules
- private endpoints for workload services
- workload-local RBAC and diagnostics wiring

## What It Reads From

- `platform-v2/connectivity` remote state
  - Uses hub VNet and Private DNS information.
- `platform-v2/management` remote state
  - Uses the shared Log Analytics workspace.
- optional `platform-v2/identity` remote state
  - Uses shared identities and the shared CMK when enabled.
- optional `global/subscriptions` remote state
  - Used for subscription validation.

## Main Inputs

- `subscription_id`
  - Makes the workload subscription explicit and auditable.
- `location`
  - Defines where the workload landing zone lives.
- `workload_resource_group_name`
  - Gives the workload its own clear resource boundary.
- `spoke_vnet_name` and `spoke_address_space`
  - Define the spoke network that connects the app to the platform hub.
- service-name inputs
  - Keep storage, Key Vault, SQL, APIM, and other workload resources consistent
    and readable.
- feature toggles such as `enable_service_bus`, `enable_sql`, `enable_function_app`
  - Let the team grow the landing zone gradually without forcing every service
    to be deployed at once.
- remote-state backend settings
  - Tell the stack where to find shared platform outputs.

## What This Stack Does

- validates the workload subscription against the central catalog when enabled
- reads shared platform state
- creates the workload resource group
- creates the spoke VNet and workload subnets
- peers the spoke back to the hub
- links the spoke to the shared Private DNS zones
- creates Application Insights on top of the shared workspace
- creates the workload storage account and Key Vault
- optionally creates App Configuration, Service Bus, SQL, ACR, Function App,
  APIM, and Azure DevOps resources
- creates private endpoints for services that require private access
- optionally creates a low-cost Windows validation VM for testing private
  networking and managed identity access

## What Other Stacks Use From It

This stack is usually the consumer edge of the pattern rather than a shared
provider, but its outputs are still useful.

Typical consumers include:

- application deployment pipelines
- release automation
- operator and validation scripts

Common outputs from this stack include:

- resource group name
- spoke VNet ID
- workload Key Vault URI
- storage account name
- optional service names such as Function App, Service Bus, SQL, or APIM

## Main Building Blocks

Core platform-consumption blocks:

- tags
- resource group
- spoke network
- hub peering
- shared Private DNS links
- Application Insights
- storage account
- Key Vault
- role assignments

Optional workload service blocks:

- App Configuration
- Service Bus
- SQL
- container registry
- Function App
- API Management
- Azure DevOps helpers

Private connectivity blocks:

- storage private endpoints
- Key Vault private endpoint
- service-specific private endpoints for optional services

Validation helpers:

- dependency guards
- optional Windows validation VM

## Code Map

- `data.tf`
  - Reads shared platform state and enforces dependency checks.
- `locals.tf`
  - Defines subnet layout, role-assignment maps, and effective identity logic.
- `main.tf`
  - Composes the workload landing zone.
- `outputs.tf`
  - Publishes outputs used by deployment automation and operators.
- `dev.tfvars`
  - Holds the current reference configuration for this environment.

## How To Extend It

- Use this stack as the pattern for new workload roots.
- Add new workload service modules behind clear feature flags.
- Keep shared services in platform stacks unless they are truly workload-local.
- Publish new shared dependencies from platform stacks instead of hardcoding
  platform resource IDs here.
- Prefer managed identities and private networking over public access and
  embedded secrets.

## Best-Practice Notes

This stack is the clearest example of how teams should grow the pattern across
the organization.

The key idea is simple:

- governance is inherited from the global layer
- shared services come from the platform layer
- workload-specific resources stay in the workload layer

That split keeps ownership clear and makes it much easier for onboarded
engineers to know where new code should go.
