# Global Platform Management Bootstrap

## Purpose

This directory is reserved for a future global management bootstrap layer above
the environment-scoped `platform-v2/management` stacks.

It is the place to put truly shared corporate management services when they are
not owned by one environment platform subscription.

## Current State

- documentation-only
- no active Terraform root in this directory today

## Intended Responsibilities

If activated, this root would typically own services such as:

- centrally shared Log Analytics or SIEM ingestion foundations
- cross-environment action groups
- tenant-wide diagnostic export patterns
- shared automation, update, or monitoring primitives that sit above a single
  environment

## Relationship To Other Stacks

- would serve environment `platform-v2/management` stacks
- would sit below `global/*` governance and above environment platform stacks
- should not own app-specific diagnostics or workload-local alerting

## Best-Practice Context

Use this only when the management plane is genuinely shared above environment
scope. Otherwise keep management services in the environment platform boundary
where blast radius and ownership stay clearer.
