# Global Role Assignments

## Purpose

This stack seeds the high-scope Azure RBAC assignments for the landing zone
pattern.

It is for central platform and governance access, not for application-local
permissions.

For the broader design rationale, see `terraform/README-v2.md`.

## Why This Stack Exists

- High-scope roles should be managed separately from workload-local RBAC.
- Platform teams need access before environment and workload stacks can run.
- Central RBAC is easier to audit when it is kept in one place.

## What This Stack Owns

- management-group and other centrally scoped role assignments
- the mapping between platform personas and Azure roles at high scope

## What It Reads From

- `global/management-groups` remote state
  - Uses management group IDs for assignment scope.
- direct principal ID inputs
  - Used to tell the stack which Entra groups, service principals, or managed
    identities should receive which roles.

## Main Inputs

- management group IDs
  - Define where each assignment should land.
- principal IDs
  - Identify the groups or identities that need central access.
- role mapping inputs
  - Tell the stack which personas should get contributor, reader, or admin
    rights.

## What This Stack Does

- reads the management group hierarchy
- validates that prerequisite branches exist
- builds a normalized assignment map
- creates the requested RBAC assignments only when the matching principal ID is
  supplied

Typical assignments in this stack are:

- platform deployer roles
- security reader roles
- shared nonprod workload operator roles
- shared prod reader roles

## What Other Stacks Use From It

This stack mostly serves the estate operationally rather than through data
outputs.

Its main effect is that:

- central deployers already have access before running platform stacks
- central readers already have visibility across the estate
- workload stacks do not need to bootstrap tenant-wide or management-group-wide
  access themselves

## Main Building Blocks

- `module "role_assignments"`
  - Creates the RBAC assignments from the computed map.
- `terraform_data.dependency_guard`
  - Stops planning if management group prerequisites are missing.

## Code Map

- `main.tf`
  - Reads management group state and builds the assignment map.
- `outputs.tf`
  - Publishes assignment IDs for audit and troubleshooting.
- `global.auto.tfvars`
  - Supplies principal IDs and assignment settings.

## How To Extend It

- Add new central personas here when the scope is truly management-group-wide
  or broader.
- Keep resource-group and resource-level RBAC in platform or workload stacks
  unless the access must be shared centrally.
- Review new assignments carefully because this stack has a large blast radius.

## Best-Practice Notes

This separation is important.

If high-scope RBAC and workload-local RBAC are mixed together, engineers have a
hard time understanding who owns access and why. Keeping central assignments in
this stack makes the access model much easier to explain and scale.
