# Global Platform Connectivity Bootstrap

## Purpose

This directory is reserved for a future global connectivity bootstrap layer
above the environment-scoped `platform-v2/connectivity` stacks.

It is the place to put shared corporate network constructs when multiple
environments or landing zones consume the same upper-tier connectivity plane.

## Current State

- documentation-only
- no active Terraform root in this directory today

## Intended Responsibilities

If activated, this root would typically own services such as:

- globally shared DNS forwarding foundations
- corporate edge or transit connectivity constructs
- shared virtual WAN shells or top-level routing assets
- early bootstrap network resources that multiple environment hubs depend on

## Relationship To Other Stacks

- would serve environment `platform-v2/connectivity` stacks
- would sit below `global/*` governance and above environment platform stacks
- should not own workload spokes directly

## Best-Practice Context

Only use this layer if connectivity is truly shared above environment scope.
Otherwise keep hub networking inside the environment platform boundary so
ownership and routing changes remain easier to reason about.
