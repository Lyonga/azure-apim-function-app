# Global Subscriptions

## Purpose

This root is the subscription catalog for the landing zone.

It does not currently create subscriptions. Instead, it normalizes the logical
subscription inventory, records where each subscription belongs in the
management group tree, and exposes that catalog to other stacks through remote
state.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- accepts `var.target_subscriptions` as the source of truth
- normalizes each entry into a predictable object shape
- trims whitespace from `existing_subscription_id`
- defaults `subscription_display_name` to the map key when not provided
- builds `subscription_catalog` as the normalized inventory
- builds `subscriptions_by_group` as a reverse index of
  `management_group_key => list(subscription_ids)`

That reverse index is what downstream stacks use when they need to operate per
management group instead of per individual subscription entry.

## What It Consumes

- `var.target_subscriptions`
  - one entry per logical landing-zone role
  - each entry includes the target `management_group_key`
  - each entry includes an existing subscription ID, or an empty placeholder

## Child Modules And Resources

This root is intentionally simple:

- no child modules
- no Azure resources
- locals plus outputs only

That makes it safe to apply early and frequently.

## What It Serves To Other Stacks

This root exposes:

- `subscription_catalog`
  - consumed by environment platform and workload stacks to validate that their
    explicit `subscription_id` matches the central catalog
- `subscriptions_by_group`
  - consumed by `global/management-groups` to attach subscriptions to the right
    management groups

## Code Map

- `main.tf`: normalization and grouping logic
- `outputs.tf`: catalog and group-index outputs
- `global.auto.tfvars`: defines the active subscription inventory

## How To Extend It

- add more metadata to each catalog entry, such as environment, cost center, or
  owner
- keep normalization separate from enrichment so downstream stacks continue to
  receive a stable shape
- if you later automate subscription creation, feed the created subscription IDs
  back into this catalog before management group attachment

## Best-Practice Context

This stack is effectively the inventory and placement layer for the estate. It
keeps subscription targeting explicit and auditable instead of hiding those
relationships in individual stack tfvars files.
