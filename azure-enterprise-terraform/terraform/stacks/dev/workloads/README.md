# Dev Workloads (Legacy)

## Purpose

This is the legacy pre-v2 workload root.

It is kept as a reference for the earlier workload pattern, but it is not the
preferred enterprise model in this repository.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- It shows the older approach used before the v2 platform split.
- It is useful when comparing the legacy model to the newer workload-v2 model.
- It helps explain why the v2 pattern is easier to scale.

## What This Stack Owns

- a legacy workload composition path
- optional VM, load-balancer, observability, Function App, Key Vault, storage,
  and APIM resources

Unlike `workload-v2`, this stack does not clearly separate platform
dependencies into dedicated connectivity, management, and identity planes.

## What It Reads From

- optional global remote state
  - Supplies the workload resource group name and location.
- optional platform remote state
  - Supplies shared subnet IDs.
- direct tfvars
  - Supply runtime settings, names, and tags.

## Main Inputs

- legacy resource-group and location inputs
  - Either come from shared state or direct variables.
- platform subnet inputs
  - Used to place resources into existing network space.
- service-name and runtime inputs
  - Control which workload resources are created.

## What This Stack Does

- optionally reads a globally managed workload resource group and location
- optionally reads shared subnet state
- validates that legacy dependencies exist
- can create:
  - a Linux validation VM
  - a public IP and load balancer
  - observability resources
  - a Function App
  - a Key Vault
  - a storage account
  - API Management
  - VM-related role assignments

## What Other Stacks Use From It

This root is mostly self-contained and does not publish a large shared
contract.

Its outputs are mainly for validation and operator use.

## Main Building Blocks

- VM
- public IP
- load balancer
- observability
- Function App
- Key Vault
- storage account
- APIM
- VM role assignments
- input guard

## Code Map

- `data.global.tf`
  - Reads the shared workload resource group and location when enabled.
- `data.platform.tf`
  - Reads legacy platform subnet outputs when enabled.
- `locals.tf`
  - Handles naming, tags, and dependency checks.
- `main.tf`
  - Composes the legacy workload pattern.
- `outputs.tf`
  - Publishes validation outputs.
- `dev.tfvars`
  - Holds the legacy environment example values.

## How To Extend It

- Only extend this stack if you intentionally need to maintain the legacy
  pattern.
- Put new landing zones into `workload-v2` instead.
- If you must keep using this root, document its dependencies very clearly
  because they are less obvious than in v2.

## Best-Practice Notes

This stack is still useful as a learning reference, but it is not the best
long-term enterprise pattern.

The v2 workload model is clearer because:

- the workload owns its own resource group
- platform services are split into separate stacks
- dependencies are easier for new engineers to trace
