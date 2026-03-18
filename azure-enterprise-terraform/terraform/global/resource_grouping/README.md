# Global Resource Grouping

## Purpose

This stack is a legacy helper that centrally creates a standard workload
resource group and publishes its name and location for downstream use.

It mainly supports the older `stacks/dev/workloads` pattern.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- Some organizations prefer to control workload resource groups centrally.
- The older workload pattern in this repository expects the resource group name
  and location to come from a shared global stack.
- It provides a simple reference for centrally managed naming and placement.

## What This Stack Owns

- one standard workload resource group
- the naming and tag model applied to that resource group

## What It Reads From

- environment and project naming inputs
- location inputs
- common ownership and cost tags

## Main Inputs

- `environment`
  - Used to make the resource group name environment-aware.
- `project_name`
  - Used to keep the name readable and tied to a business or application
    domain.
- `workload_rg_location`
  - Defines where the resource group should be created.
- ownership and cost tags
  - Ensure that even a simple RG scaffold follows the tagging standard.

## What This Stack Does

- builds a standard resource group name
- applies the common tag model
- creates the resource group through the shared `resource_group` module
- publishes the resource group name and location for downstream consumers

## What Other Stacks Use From It

- `stacks/dev/workloads`
  - Reads the resource group name and location from this stack.

The v2 workload pattern does not usually depend on this stack because new
workload roots own their resource group directly.

## Main Building Blocks

- `module "workload_rg"`
  - Creates the resource group.

This stack is intentionally small because it is a legacy scaffolding helper,
not a full platform stack.

## Code Map

- `locals.tf`
  - Builds naming and common tags.
- `main.tf`
  - Creates the resource group.
- `outputs.tf`
  - Publishes the resource group name and location.
- `dev.auto.tfvars`
  - Supplies legacy reference values.

## How To Extend It

- Add more standard resource groups only if central RG ownership is a deliberate
  design choice.
- Do not treat this as the default pattern for new v2 workloads.
- Prefer workload-owned RGs in `workload-v2` unless your operating model
  specifically requires central RG lifecycle control.

## Best-Practice Notes

This is still an acceptable enterprise pattern when central RG ownership is the
goal.

The newer v2 pattern is usually better because it makes workload ownership more
explicit.

### Why The V2 "Stack Owns Its Resource Group" Pattern Is Usually Best

- ownership is clearer
- state and lifecycle stay together
- there are fewer hidden dependencies between stacks
- teams can add or remove landing zones without touching a central resource
  group stack
- blast radius is easier to reason about

### When Centralizing Resource Group Creation Can Still Be The Better Choice

- a central platform team must own all resource group lifecycle
- resource groups need pre-applied locks, budgets, or special RBAC before any
  workload code runs
- the organization wants very strict centralized control over naming and
  placement

### Practical Recommendation

- use the v2 pattern as the default for new platform and workload stacks
- centralize standards through shared modules, tags, policy, and naming rules
- only centralize resource group creation if the operating model explicitly
  requires central ownership of resource group lifecycle

This stack is best understood as a legacy reference, not the default path for
new landing zones.
