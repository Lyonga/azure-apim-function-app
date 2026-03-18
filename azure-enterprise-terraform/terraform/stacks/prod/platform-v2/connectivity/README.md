# Prod Platform V2 Connectivity Placeholder

## Purpose

This folder is the future production shared connectivity stack.

When activated, it should own the production hub network and the production
shared Private DNS foundation.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Serve

- `prod` identity stack
- `prod` workload stacks

## Expected Subscription Role

- platform or dedicated connectivity subscription:
  `<replace-with-prod-platform-or-connectivity-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/platform-v2/connectivity`, keep the same ownership
model, and only replace environment-specific values.
