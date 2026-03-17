# Dev Platform V2 Management

## Purpose

This stack is the shared monitoring and operations layer for the dev platform
plane.

It creates the common observability and recovery services that platform and
workload stacks send telemetry into.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- optionally validates its `subscription_id` against the central subscriptions
  catalog
- creates the management resource group
- creates the shared Log Analytics workspace
- creates the diagnostics archive storage account
- optionally creates a Log Analytics storage insights connection
- creates the operations action group
- creates the Recovery Services vault
- enables a monitoring baseline for subscription activity logs

## What It Consumes

- explicit naming, region, and tagging inputs
- optional `global/subscriptions` remote state for subscription validation

This stack does not require connectivity or identity state to stand up its core
services.

## Child Modules And Resources

- `module "tags"`
- `module "resource_group"`
- `module "workspace"`
  - shared Log Analytics workspace
- `module "diagnostics_archive"`
  - private diagnostics storage account
- `azurerm_log_analytics_storage_insights.diagnostics_archive`
  - optional archive insight wiring
- `module "action_group"`
  - alert notification target
- `module "recovery_services_vault"`
- `module "monitoring_baseline"`
  - subscription activity log baseline

## What It Serves To Other Stacks

This stack publishes shared management-plane values:

- `resource_group_name`
- `workspace_id`
- `workspace_name`
- `diagnostics_storage_account_id`
- `action_group_id`
- `recovery_services_vault_id`

Consumers:

- `platform-v2/identity`
- `workload-v2/finserv-api`

## Code Map

- `data.tf`: optional subscription-catalog validation
- `main.tf`: workspace, archive, alerts, recovery, monitoring baseline
- `outputs.tf`: management-plane outputs for downstream stacks
- `dev.tfvars`: management naming and retention choices

## How To Extend It

- add more shared diagnostics baselines here rather than scattering them across
  workloads
- add platform-wide action groups or alert rules that multiple stacks use
- keep workload-local alerts inside the workload stack unless they are meant to
  standardize across the estate

## Best-Practice Context

This is the right place for environment-shared monitoring and diagnostics. It
gives workloads one known management destination instead of many ad hoc
workspaces and alerting models.
