# Test Environment Placeholder

## Purpose

This folder is the future home of the `test` environment for the v2 landing
zone pattern.

It mirrors `dev` so teams can validate the same architecture in another
non-production environment before promotion to production.

## Current State

- scaffold only
- not an active deployment target yet

## What This Environment Will Contain

- `platform-v2/connectivity`
- `platform-v2/management`
- `platform-v2/identity`
- `workload-v2/*`

The global governance stacks remain shared in `terraform/global/*`.

## Why This Folder Exists

- It provides a clean promotion step between `dev` and `prod`.
- It gives teams a place to test environment-specific configuration without
  changing the global or platform architecture.
- It encourages reuse of the same stack boundaries across environments.

## Before Activating It

Replace the placeholders with real test values for:

- platform subscription ID
- workload subscription ID
- backend keys under `stacks/test/...`
- test naming, tags, and approvals

## How To Use It

- promote the structure from `stacks/dev`
- keep the same stack ownership model
- add only the environment-specific values required for `test`

If a client needs more non-production environments such as `qa` or `stage`,
copy this same structure instead of creating a different pattern.
