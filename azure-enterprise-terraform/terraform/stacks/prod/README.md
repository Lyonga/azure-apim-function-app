# Prod Environment Placeholder

## Purpose

This folder is the future home of the `prod` environment for the v2 landing
zone pattern.

It mirrors the `dev` structure so teams can promote the same design into
production without inventing a different layout.

## Current State

- scaffold only
- not an active deployment target yet

## What This Environment Will Contain

- `platform-v2/connectivity`
- `platform-v2/management`
- `platform-v2/identity`
- `workload-v2/*`

The global governance stacks stay shared at the `terraform/global/*` layer.

## Why This Folder Exists

- It gives teams a clear promotion path from `dev` to `prod`.
- It keeps the environment structure consistent across the repository.
- It shows where production-specific values and approvals will live.

## Before Activating It

Replace the placeholders with real production values for:

- platform subscription ID
- workload subscription ID
- backend keys under `stacks/prod/...`
- production naming, tags, and approval controls

## How To Use It

- copy the proven structure from `stacks/dev`
- keep the same stack boundaries
- change only environment-specific values, not the core architecture

That approach makes the pattern easier for teams to understand and reuse across
the organization.
