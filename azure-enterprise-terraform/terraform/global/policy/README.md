# Global Policy

## Purpose

This stack defines and assigns the shared Azure Policy controls for the landing
zone pattern.

It is the main governance enforcement layer in the repository.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- Governance rules should be defined once and applied consistently.
- Platform and workload stacks should inherit guardrails instead of trying to
  rebuild them locally.
- Central policy assignments make the enterprise pattern easier to scale across
  more subscriptions and landing zones.

## What This Stack Owns

- custom policy definitions
- policy set definitions (initiatives)
- management-group policy assignments

Its real output is governance behavior, not just Terraform outputs.

## What It Reads From

- `global/management-groups` remote state
  - Uses management group IDs so it can assign policy at the correct scope.
- direct governance inputs
  - Used for settings like allowed locations, required tags, and organization
    naming.

## Main Inputs

- `allowed_locations`
  - Controls where teams are allowed to deploy resources.
  - This is one of the simplest and most effective guardrails to scale
    centrally.
- `required_tags`
  - Forces a minimum metadata standard across subscriptions and resource groups.
  - This supports cost reporting, ownership, and operational support.
- management group IDs
  - Tell the stack which branch should receive each initiative.

## What This Stack Does

- reads management group IDs from `global/management-groups`
- validates that the expected hierarchy exists
- defines reusable custom policies
- groups those policies into initiatives
- assigns initiatives to the correct management group branches

Examples of controls in this stack include:

- allowed locations
- required tags
- private networking enforcement
- public IP restrictions
- service-specific network guardrails

## Current Policy Inventory

This section lists the policies that are currently implemented in
[`main.tf`](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/azure-enterprise-terraform/terraform/global/policy/main.tf).

### Custom Policy Definitions

#### Root-Scope Definitions

These definitions are created at the tenant root management group so they can
be used by the platform initiative.

- `allowed_locations_root`
  - Display name: `Allow approved Azure regions (root)`
  - Effect: `deny`
  - Purpose: blocks resources deployed outside the approved region list, except
    for `global` resources
- `required_tag_root`
  - Display name: `Require enterprise tag (root)`
  - Effect: `deny`
  - Purpose: blocks resources that do not include a required enterprise tag
  - Note: this does not apply to resource groups themselves because the policy
    explicitly excludes `Microsoft.Resources/subscriptions/resourceGroups`

#### Landing-Zone Definitions

These definitions are created at the `landing_zones` management group and are
used by the landing-zone baseline initiative.

- `allowed_locations`
  - Display name: `Allow approved Azure regions`
  - Effect: `deny`
  - Purpose: blocks resources deployed outside the approved region list, except
    for `global` resources
- `required_tag`
  - Display name: `Require enterprise tag`
  - Effect: `deny`
  - Purpose: blocks resources that do not include a required enterprise tag
- `deny_public_ip`
  - Display name: `Deny public IP creation`
  - Effect: `deny`
  - Purpose: blocks creation of `Microsoft.Network/publicIPAddresses`
- `deny_storage_public_network`
  - Display name: `Deny public network access for storage accounts`
  - Effect: `deny`
  - Purpose: requires `Microsoft.Storage/storageAccounts/publicNetworkAccess`
    to be `Disabled`
- `deny_key_vault_public_network`
  - Display name: `Deny public network access for Key Vault`
  - Effect: `deny`
  - Purpose: requires `Microsoft.KeyVault/vaults/publicNetworkAccess` to be
    `Disabled`
- `deny_service_bus_public_network`
  - Display name: `Deny public network access for Service Bus`
  - Effect: `deny`
  - Purpose: requires `Microsoft.ServiceBus/namespaces/publicNetworkAccess` to
    be `Disabled`
- `deny_app_configuration_public_network`
  - Display name: `Deny public network access for App Configuration`
  - Effect: `deny`
  - Purpose: requires
    `Microsoft.AppConfiguration/configurationStores/publicNetworkAccess` to be
    `Disabled`
- `deny_sql_public_network`
  - Display name: `Deny public network access for SQL servers`
  - Effect: `deny`
  - Purpose: requires `Microsoft.Sql/servers/publicNetworkAccess` to be
    `Disabled`
- `deny_webapp_public_network`
  - Display name: `Deny public network access for App Service workloads`
  - Effect: `deny`
  - Purpose: requires `Microsoft.Web/sites/publicNetworkAccess` to be
    `Disabled`

### Policy Set Definitions

- `platform_foundation`
  - Display name: `FinServ Platform Foundation`
  - Scope: root management group
  - Includes:
    - `allowed_locations_root`
    - one `required_tag_root` reference for each required tag
- `landing_zone_baseline`
  - Display name: `FinServ Landing Zone Baseline`
  - Scope: `landing_zones` management group
  - Includes:
    - `allowed_locations`
    - one `required_tag` reference for each required tag
    - `deny_public_ip`
    - `deny_storage_public_network`
    - `deny_key_vault_public_network`
    - `deny_service_bus_public_network`
    - `deny_app_configuration_public_network`
    - `deny_sql_public_network`
    - `deny_webapp_public_network`

### Policy Assignments

- `platform`
  - Display name: `Platform Foundation`
  - Assigned to: `platform` management group
  - Initiative: `platform_foundation`
- `prod`
  - Display name: `Prod Landing Zone Baseline`
  - Assigned to: `prod` management group
  - Initiative: `landing_zone_baseline`
- `nonprod`
  - Display name: `Nonprod Landing Zone Baseline`
  - Assigned to: `nonprod` management group
  - Initiative: `landing_zone_baseline`

## Current Active Parameters

These are the current active policy parameters in
[`global.auto.tfvars`](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/azure-enterprise-terraform/terraform/global/policy/global.auto.tfvars)
and [`variables.tf`](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/azure-enterprise-terraform/terraform/global/policy/variables.tf).

### Allowed Locations

The currently approved regions are:

- `eastus`
- `eastus2`
- `centralus`

### Required Tags

The current required enterprise tags are:

- `env`
- `application`
- `created_by`
- `bt_owner`
- `source_repo`
- `tf_workspace`
- `recovery`
- `cost_center`

## Why There Are Root And Landing-Zone Versions

There are separate root-scope and landing-zone-scope versions of the location
and required-tag definitions because the stack builds two different
initiatives:

- one for the platform branch
- one for the landing-zone branches

This keeps the policy assignment model simple:

- platform gets the shared foundation controls
- prod and nonprod workloads get the full landing-zone baseline

## What Other Stacks Use From It

Every platform and workload stack uses this stack indirectly through policy
inheritance.

In practice this means:

- platform stacks are evaluated against platform guardrails
- workload stacks are evaluated against landing-zone guardrails
- engineers can trust that common controls are already in place before they
  extend the pattern

## Main Building Blocks

- `azurerm_policy_definition`
  - Defines reusable custom policies.
- `azurerm_policy_set_definition`
  - Groups policies into initiatives that are easier to assign and manage.
- `azurerm_management_group_policy_assignment`
  - Applies the initiatives at the correct management group scope.
- `terraform_data.dependency_guard`
  - Prevents plans when prerequisite management groups do not exist yet.

## Code Map

- `main.tf`
  - Defines policy resources and assignments.
- `outputs.tf`
  - Publishes initiative IDs and referenced management group IDs.
- `global.auto.tfvars`
  - Supplies governance settings such as locations and required tags.

## How To Extend It

- Add new policy definitions when you introduce new enterprise controls.
- Prefer adding policies to initiatives instead of scattering one-off
  assignments.
- Keep tenant-wide and management-group-wide enforcement here, not in workload
  stacks.
- Use
  [`policy-draft.tf`](/Users/charleslyonga/Documents/azure-cloud/azure-apim-function-app/azure-enterprise-terraform/terraform/global/policy/policy-draft.tf)
  as the backlog for proposed but not-yet-approved controls.

## Best-Practice Notes

This is the right enterprise pattern because policy should be owned centrally
and inherited downward.

When policy logic is embedded inside workload stacks, governance becomes
inconsistent and much harder to review. This stack avoids that by making policy
part of the shared control plane.
