# Global Subscriptions

## Purpose

This stack is the central subscription catalog for the landing zone pattern.

It does not currently create Azure subscriptions. Its job is to describe which
subscriptions exist, what role each one plays, and which management group each
subscription should live under.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- It gives the project one source of truth for subscription IDs.
- It keeps management group placement out of individual platform and workload
  stacks.
- It lets governance stacks target subscriptions consistently instead of
  relying on hardcoded IDs in many places.
- It gives new engineers one place to understand the subscription model before
  reading the rest of the code.

## What This Stack Owns

This stack owns the subscription inventory only.

It does not create Azure resources. It creates normalized locals and outputs
that other stacks read through remote state.

## What It Reads From

- `var.target_subscriptions`
  - This is the main input to the stack.
  - Each entry describes one logical subscription role in the pattern.
  - Each entry tells the stack which management group that subscription should
    belong to.

## Main Inputs

- `target_subscriptions`
  - The source of truth for the subscription catalog.
  - Use this to add a new platform, workload, sandbox, or retired subscription
    role.
- `management_group_key`
  - Tells downstream governance stacks where the subscription belongs in the
    management group hierarchy.
- `existing_subscription_id`
  - The actual Azure subscription ID to attach.
  - It is trimmed to avoid failures caused by accidental whitespace.
- `subscription_display_name`
  - Optional friendly name.
  - If not supplied, the stack falls back to the map key so downstream code
    still has a readable value.

## How The Locals Work

### `normalized_subscriptions`

This local cleans and standardizes the raw input.

It makes sure downstream code can always expect:

- a `management_group_key`
- a trimmed `existing_subscription_id`
- a `subscription_display_name`

Why this matters:

- governance and platform stacks should not have to re-validate subscription
  input shape
- small input issues, like trailing spaces, should be fixed once in a central
  place

### `subscription_catalog`

This local is the normalized inventory that other stacks consume.

Right now it mirrors `normalized_subscriptions`, but keeping it separate makes
future extension easier. For example, you can later enrich the catalog with:

- environment
- cost center
- owner
- support team
- business unit

without changing the earlier normalization step.

### `subscriptions_by_group`

This local builds the reverse index that governance stacks need:

- `management_group_key => list(subscription_ids)`

Why this matters:

- management groups attach subscriptions by group, not by arbitrary catalog key
- policy and RBAC are often applied by management group branch
- this makes it easy to loop per management group instead of manually building
  lists in many places

## What Other Stacks Use From It

- `global/management-groups`
  - Uses `subscriptions_by_group` to attach subscriptions to the correct
    management groups.
- `global/policy`
  - Indirectly depends on this stack because policy assignments follow the
    management group structure built from this catalog.
- `global/role-assignments`
  - Indirectly depends on this stack for the same reason.
- `platform-v2/*` and `workload-v2/*`
  - Can validate that their explicit `subscription_id` matches the central
    subscription catalog.

## Main Building Blocks

- `locals`
  - Normalize, enrich, and group subscription metadata.
- `outputs`
  - Publish the catalog and group index to downstream stacks.

This stack is intentionally simple because it should be safe to apply early and
often.

## Code Map

- `main.tf`
  - Builds the normalized catalog and management-group index.
- `outputs.tf`
  - Publishes the catalog for downstream stacks.
- `global.auto.tfvars`
  - Defines the active subscription inventory for the project.

## How To Extend It

- Add more metadata to each subscription entry when the organization grows.
- Keep this stack focused on subscription inventory and placement.
- If you later automate subscription creation, write the created subscription
  IDs back into this catalog before attaching them to management groups.

## Best-Practice Notes

This is a strong enterprise pattern because subscription ownership and
placement are explicit and auditable.

Without this stack, subscription IDs tend to get scattered across platform and
workload roots. That makes governance harder to scale and much harder for new
engineers to understand.
