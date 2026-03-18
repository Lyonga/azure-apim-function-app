# Prod Platform V2 Identity Placeholder

## Purpose

This folder is the future production shared identity stack.

When activated, it should own the reusable managed identities, shared Key
Vault, and shared key services for production workloads.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Serve

- production platform automation
- production workload stacks that consume shared identities or shared keys

## Expected Subscription Role

- platform or dedicated identity or shared-services subscription:
  `<replace-with-prod-platform-or-identity-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/platform-v2/identity`, keep the same boundary between
shared identity assets and workload-local identities, and only replace
environment-specific values.
