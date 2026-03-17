# Global Management Groups

## Purpose

This root owns the Azure management group hierarchy for the landing zone.

It sits above every environment and workload stack and gives policy and RBAC a
stable inheritance structure. In this repo, it is the bridge between the
logical subscription catalog in `global/subscriptions` and the real management
group layout used by downstream governance stacks.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- reads subscription placement metadata from `global/subscriptions` remote state
- merges that state with any directly supplied `subscriptions_by_group` values
- validates that the subscriptions catalog has already been applied
- creates the management group hierarchy through the shared
  `modules/management_groups` module
- associates existing subscription IDs to the correct management groups

In the active demo, this hierarchy includes the shared platform and landing-zone
branches, while connectivity, management, and identity still deploy into the
same platform subscription.

## What It Consumes

- `var.root_management_group_id`
- `var.organization_prefix`
- `var.organization_display_name`
- `var.use_subscriptions_state`
- the `subscriptions_by_group` output from `global/subscriptions`

## Child Modules And Resources

- `module "management_groups"`
  - creates the management group tree
  - attaches subscriptions to their target management groups
- `terraform_data.dependency_guard`
  - stops plans if the subscriptions catalog has not been applied yet

## What It Serves To Other Stacks

This root exposes:

- `management_group_ids`
  - consumed by `global/policy`
  - consumed by `global/role-assignments`
- `root_management_group_id`
  - reused by `global/policy`
- `subscriptions_by_group`
  - records the effective placement used for the hierarchy

## Code Map

- `main.tf`: reads remote state, validates dependencies, creates the hierarchy
- `outputs.tf`: publishes management group IDs and effective placement
- `global.auto.tfvars`: supplies tenant and organization-specific settings

## How To Extend It

- add new landing-zone branches in `modules/management_groups`
- add new logical subscription roles in `global/subscriptions`
- keep policy and RBAC aligned with any new management group keys you introduce

## Best-Practice Context

This is the correct place for management group structure because management
groups are tenant-scoped governance primitives, not environment resources.
Centralizing them here matches the Azure Landing Zone guidance followed by the
v2 pattern.
