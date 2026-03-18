# Test Platform V2 Management Placeholder

## Purpose

This folder is the future test shared management stack.

When activated, it should own the shared monitoring, archive, alerting, and
recovery services for the test environment.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Serve

- test platform stacks
- test workload stacks that send telemetry to the shared management plane

## Expected Subscription Role

- platform or dedicated management subscription:
  `<replace-with-test-platform-or-management-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/platform-v2/management` when the test environment is
ready. Keep the same shared management model.
