# Global Management Groups

## Purpose

This stack creates the Azure management group hierarchy for the landing zone
pattern.

It is the structure that governance stacks use to apply policy and RBAC at the
right scope.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- Azure Policy and high-scope RBAC work best when subscriptions are organized
  under a clear management group tree.
- Platform and workload subscriptions should inherit governance from a shared
  structure instead of being configured one by one.
- A stable management group hierarchy gives the rest of the project a common
  operating model.

## What This Stack Owns

- the management group hierarchy
- subscription-to-management-group associations

This is a tenant-level governance stack. It is not an environment stack.

## What It Reads From

- `global/subscriptions` remote state
  - Uses the central subscription catalog to determine which subscriptions
    belong in which management group.
- direct variables
  - Used for organization naming and root management group settings.

## Main Inputs

- `root_management_group_id`
  - The tenant root or parent management group under which this hierarchy is
    created.
- `organization_prefix`
  - Keeps management group names consistent across the estate.
- `organization_display_name`
  - Makes the hierarchy readable in Azure.
- `use_subscriptions_state`
  - Controls whether the stack should trust the remote catalog from
    `global/subscriptions`.
- `subscriptions_by_group`
  - Optional direct input for subscription placement if remote state is not
    used.

## What This Stack Does

- reads the subscription placement model from `global/subscriptions`
- validates that the subscription catalog exists before planning
- creates the management group tree through the shared
  `modules/management_groups` module
- attaches existing subscriptions to the correct management groups

## What Other Stacks Use From It

- `global/policy`
  - Uses management group IDs to assign policy at the correct branches.
- `global/role-assignments`
  - Uses management group IDs to apply high-scope RBAC.
- future governance stacks
  - Can target the same hierarchy without rebuilding it.

This stack is one of the main foundations for the rest of the governance layer.

## Main Building Blocks

- `module "management_groups"`
  - Creates the hierarchy and attaches subscriptions.
- `terraform_data.dependency_guard`
  - Stops plans if the subscription catalog has not been applied yet.

## Code Map

- `main.tf`
  - Reads the subscription catalog and creates the hierarchy.
- `outputs.tf`
  - Publishes management group IDs for downstream governance stacks.
- `global.auto.tfvars`
  - Supplies organization-specific hierarchy settings.

## How To Extend It

- Add new branches when the organization needs new landing-zone types.
- Keep management group keys aligned with the keys defined in
  `global/subscriptions`.
- When you add new branches, update policy and RBAC stacks so they use the new
  structure.

## Best-Practice Notes

This is the correct place for management groups because they are tenant-scoped
governance primitives.

Keeping management groups in a separate global stack makes it much easier to:

- review governance changes separately from workload releases
- apply policy and RBAC consistently
- onboard new engineers who need to understand the control-plane model first
