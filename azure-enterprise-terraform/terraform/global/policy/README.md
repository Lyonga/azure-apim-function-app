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

## Best-Practice Notes

This is the right enterprise pattern because policy should be owned centrally
and inherited downward.

When policy logic is embedded inside workload stacks, governance becomes
inconsistent and much harder to review. This stack avoids that by making policy
part of the shared control plane.
