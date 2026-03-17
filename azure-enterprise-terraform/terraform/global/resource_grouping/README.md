# Global Resource Grouping

## Purpose

This root is a legacy-style helper for centrally creating a standard workload
resource group and publishing its name and location for downstream consumers.

It is most relevant to the older `stacks/dev/workloads` path. The v2 workload
pattern prefers the workload stack to own its resource group directly.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- computes a standard resource group name from environment and project inputs
- applies a common tagging model
- creates one workload resource group through the shared `resource_group` module
- outputs the resource group name and location for downstream use

## What It Consumes

- `var.environment`
- `var.project_name`
- `var.workload_rg_location`
- basic ownership and cost tags

## Child Modules And Resources

- `module "workload_rg"`
  - creates the resource group

This root is intentionally small and acts as a naming-and-placement scaffold.

## What It Serves To Other Stacks

This root exposes:

- `workload_rg_name`
- `workload_rg_location`

Those outputs are used by the legacy `stacks/dev/workloads` stack to decide
where its resources should be deployed.

## Code Map

- `locals.tf`: resource group naming and common tags
- `main.tf`: resource group creation
- `outputs.tf`: published RG name and location
- `dev.auto.tfvars`: legacy demo values

## How To Extend It

- add more standardized resource groups if you want a centrally managed legacy
  layout
- do not use this as the default pattern for new v2 workloads unless you
  intentionally want central ownership of workload RGs

## Best-Practice Context

This is an acceptable pattern for centrally managed workload placement, but it
is less explicit than the v2 model where the workload root owns its own RG. Use
it when central RG lifecycle is a deliberate design choice, not by default.
