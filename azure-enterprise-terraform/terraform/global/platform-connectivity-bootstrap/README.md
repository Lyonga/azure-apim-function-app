# Global Platform Connectivity Bootstrap

## Purpose

This directory is reserved for a future connectivity bootstrap layer above the
environment-scoped `platform-v2/connectivity` stacks.

Use it only when network services are shared above the environment level.

## Current State

- documentation only
- no active Terraform root today

## Why This Layer Would Exist

- Some organizations have a corporate network plane that many environments
  consume.
- Shared edge, transit, or top-level DNS services may need their own lifecycle.
- Keeping those constructs here prevents environment connectivity stacks from
  owning resources that are larger than their scope.

## What It Would Own

Examples of good candidates:

- top-level routing or transit constructs
- globally shared DNS forwarding foundations
- shared virtual WAN shells
- early bootstrap network resources required by many environment hubs

## What Would Use It

- `platform-v2/connectivity` stacks in each environment
- any future shared network-control stacks above a single environment

## When Not To Use It

Do not use this layer for ordinary hub networking or workload spokes.

If the resource is mainly serving one environment platform, it should stay in
that environment’s `platform-v2/connectivity` stack.
