# Prod Workload V2 FinServ API Placeholder

## Purpose

This folder is the future production workload landing zone for `finserv-api`.

When activated, it should follow the same workload-v2 pattern proven in `dev`,
but with production subscriptions, naming, approvals, and service settings.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Consume

- production connectivity outputs
- production management outputs
- production identity outputs
- shared global governance

## Expected Subscription Role

- production workload subscription:
  `<replace-with-prod-workload-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/workload-v2/finserv-api` once the production platform
stacks are active. Keep the same stack boundaries and only replace
environment-specific values.
