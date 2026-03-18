# Prod Platform V2 Management Placeholder

## Purpose

This folder is the future production shared management stack.

When activated, it should own the shared monitoring, archive, alerting, and
recovery services for the production environment.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Serve

- production platform stacks
- production workload stacks that send telemetry to the shared management plane

## Expected Subscription Role

- platform or dedicated management subscription:
  `<replace-with-prod-platform-or-management-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/platform-v2/management`, keep the same shared
management pattern, and only replace environment-specific values.
