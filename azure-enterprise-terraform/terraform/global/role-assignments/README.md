# Global Role Assignments

## Purpose

This root seeds high-scope Azure RBAC assignments for the landing zone.

It is for management group-scoped or other centrally managed access, not for
application-local role bindings. Workload stacks should still create their own
resource-group and resource-scoped RBAC where needed.

For the broader design rationale, see `terraform/README-v2.md`.

## What This Stack Does

- reads management group IDs from `global/management-groups` remote state
- validates that the expected hierarchy exists
- builds a normalized assignment map from the supplied principal IDs
- creates RBAC assignments for roles such as:
  - platform deployer contributor and user access administrator
  - security reader
  - nonprod workload deployer contributor
  - prod workload reader

Assignments are only created when the corresponding principal ID is supplied.

## What It Consumes

- `management_group_ids` from `global/management-groups`
- principal IDs supplied through variables for platform and workload operator
  personas

## Child Modules And Resources

- `module "role_assignments"`
  - consumes the computed assignment map
  - creates the RBAC resources
- `terraform_data.dependency_guard`
  - blocks plans when management group prerequisites are missing

## What It Serves To Other Stacks

This root mainly serves the estate operationally rather than through data
outputs.

It exposes:

- `assignment_ids`
  - useful for auditability and troubleshooting

Its main runtime effect is that deployers and readers already have the required
high-scope access before environment or workload stacks run.

## Code Map

- `main.tf`: remote state, dependency checks, assignment map construction
- `outputs.tf`: assignment IDs
- `global.auto.tfvars`: principal IDs and assignment inputs

## How To Extend It

- add new centrally managed personas here
- keep workload-specific access out of this root unless the scope is truly
  global or management-group-wide
- prefer management-group scope here and resource-group scope inside workload
  stacks

## Best-Practice Context

Separating high-scope RBAC from workload RBAC reduces blast radius and keeps
privileged access management clearer. This is the right root for enterprise
bootstrap identities and central reader roles.
