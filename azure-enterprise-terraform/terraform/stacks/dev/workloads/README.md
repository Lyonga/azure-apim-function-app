# Dev Workloads (Legacy)

## Purpose

This is the legacy pre-v2 workload root.

It remains useful as a reference for the earlier demo model, but it is not the
preferred enterprise pattern in this repo anymore. New landing zones should use
`stacks/dev/workload-v2/*` instead.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- optionally reads a global remote state for workload resource group name and
  location
- optionally reads a platform remote state for shared subnet IDs
- validates that required legacy dependencies exist before planning
- can create:
  - a demo Linux VM
  - a demo public IP and load balancer
  - Log Analytics and Application Insights through the observability module
  - a Function App
  - a Key Vault
  - a storage account
  - APIM
  - demo VM role assignments

## What It Consumes

- optional global remote state
  - workload resource group name
  - workload resource group location
- optional platform remote state
  - subnet IDs
- direct tfvars for resource names, runtime settings, and tags

Unlike v2, this stack does not create its own workload resource group and does
not model the newer platform-v2 connectivity, identity, and management planes
separately.

## Child Modules And Resources

- `module "vm"`
- `module "pip"`
- `module "lb"`
- `module "observability"`
- `module "function_app"`
- `module "keyvault"`
- `module "storage_account"`
- `module "apim"`
- `module "demo_vm_role_assignments"`
- `terraform_data.input_guard`

## What It Serves To Other Stacks

This root is mostly self-contained and does not expose a large downstream
contract.

Published outputs today are minimal:

- demo VM private IP
- demo public IP

## Code Map

- `data.global.tf`: optional global RG and location state
- `data.platform.tf`: optional platform subnet state
- `locals.tf`: naming, common tags, dependency checks
- `main.tf`: legacy workload composition
- `outputs.tf`: demo outputs
- `dev.tfvars`: legacy dev example values

## How To Extend It

- only extend this root if you are intentionally maintaining the legacy model
- otherwise move new work into a `workload-v2` stack
- if you keep using this root, be explicit about which global or platform
  outputs it depends on and document them carefully

## Best-Practice Context

This pattern is still acceptable for a simple centrally managed demo, but it is
less explicit than the v2 workload model. The v2 path is better because it
separates platform dependencies more clearly and lets the workload root own its
resource group and spoke networking directly.
