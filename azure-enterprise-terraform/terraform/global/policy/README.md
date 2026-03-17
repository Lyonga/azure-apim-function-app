# Global Policy

## Purpose

This root owns the shared Azure Policy definitions, policy initiatives, and
management group assignments for the landing zone.

It is the main governance enforcement layer in the repo. The other stacks do
not recreate these rules locally; they inherit them through management group
scope.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- reads management group IDs from `global/management-groups` remote state
- validates that required management group branches exist before planning
- creates reusable custom policy definitions, including:
  - allowed locations
  - required tags
  - deny public IPs
  - deny public network access for storage, Key Vault, Service Bus, App
    Configuration, SQL, and App Service workloads
- composes policy set definitions for:
  - platform foundation
  - landing zone baseline
- assigns those initiatives at the correct management group scope:
  - platform
  - prod
  - nonprod

## What It Consumes

- `management_group_ids` from `global/management-groups`
- `root_management_group_id`
- policy-specific variables such as:
  - `allowed_locations`
  - `required_tags`
  - organization naming prefixes

## Child Modules And Resources

This root mainly uses direct AzureRM policy resources:

- `azurerm_policy_definition`
- `azurerm_policy_set_definition`
- `azurerm_management_group_policy_assignment`
- `terraform_data.dependency_guard`

There is no child module abstraction here because the policy resources
themselves are the main asset being authored.

## What It Serves To Other Stacks

This root does not usually serve downstream stacks through a large output
surface. Its main effect is governance inheritance.

It exposes:

- `policy_set_ids`
  - useful if other stacks or reporting tools need to reference the initiative
    IDs
- `management_group_ids`
  - echoed from the consumed remote state for convenience

Its real value is that all platform and workload stacks are evaluated against
these assignments at deploy time.

## Code Map

- `main.tf`: definitions, initiatives, assignments, dependency guard
- `outputs.tf`: initiative IDs and referenced management group IDs
- `global.auto.tfvars`: governance parameter values for the tenant

## How To Extend It

- add new policy definitions at the landing-zone or root scope depending on
  where reuse is needed
- add new initiative members instead of scattering one-off assignments
- keep definitions and assignments in the same root only when their lifecycle is
  intentionally coupled

## Best-Practice Context

This root follows the standard pattern of defining reusable governance controls
at higher scope and assigning them to the child scopes that should inherit them.
That is stronger than embedding enforcement logic inside workload stacks.
