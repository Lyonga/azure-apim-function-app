# Global Platform Management Bootstrap

## Purpose

This directory is reserved for a future management bootstrap layer above the
environment-scoped `platform-v2/management` stacks.

Use it only when management services are shared across multiple environments or
multiple platform subscriptions.

## Current State

- documentation only
- no active Terraform root today

## Why This Layer Would Exist

- Some organizations need a higher-level management plane above individual
  environment platforms.
- Shared monitoring, automation, or diagnostic export services may need their
  own lifecycle.
- Keeping those services here avoids overloading an environment-specific
  management stack.

## What It Would Own

Examples of good candidates:

- shared Log Analytics or SIEM ingestion foundations
- cross-environment action groups
- shared diagnostic export paths
- tenant-wide or cross-environment automation primitives

## What Would Use It

- `platform-v2/management` stacks in each environment
- any future shared operations stacks that sit above a single environment

## When Not To Use It

Do not move services here just because they are important.

If a capability clearly belongs to one environment platform, keep it in that
environment’s `platform-v2/management` stack. This layer should stay small and
only hold truly shared management services.
