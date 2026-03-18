# Test Platform V2 Identity Placeholder

## Purpose

This folder is the future test shared identity stack.

When activated, it should own the reusable managed identities, shared Key
Vault, and shared key services for the test environment.

## Current State

- placeholder only
- no active Terraform root yet

## What It Will Serve

- test platform automation
- test workload stacks that consume shared identities or shared keys

## Expected Subscription Role

- platform or dedicated identity or shared-services subscription:
  `<replace-with-test-platform-or-identity-subscription-id>`

## Promotion Guidance

Promote from `stacks/dev/platform-v2/identity` when the test environment is
ready. Keep the same boundary between shared identity assets and workload-local
identities.
