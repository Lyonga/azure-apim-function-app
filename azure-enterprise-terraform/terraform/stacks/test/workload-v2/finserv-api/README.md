# Test Workload V2 FinServ API Placeholder

## Purpose

This folder is the future test workload landing zone for `finserv-api`.

When activated, it should follow the same workload-v2 pattern proven in `dev`,
but with test subscriptions, naming, and environment settings.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Consume

- test connectivity outputs
- test management outputs
- test identity outputs
- shared global governance

## Expected Subscription Role

- non-production workload subscription:
  `<replace-with-test-workload-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/workload-v2/finserv-api` once the test platform
stacks are active. Keep the same stack boundaries and only replace
environment-specific values.
