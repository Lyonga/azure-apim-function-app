# Dev Platform V2 Bootstrap

## Purpose

This directory is reserved for an optional bootstrap layer that would run
before the active `connectivity`, `management`, and `identity` stacks in the
`dev` environment.

It is for environment prerequisites that do not clearly belong to one platform
stack yet.

## Current State

- placeholder only
- no active Terraform root today

## Why This Layer Would Exist

- Some prerequisites are shared by multiple platform stacks.
- Keeping those prerequisites here can simplify dependency ordering.
- It prevents early environment setup from being scattered across several
  stacks.

## What It Would Own

Good candidates include:

- provider-registration or subscription-readiness checks
- precreated platform resource groups
- shared bootstrap storage
- early environment-wide prerequisites used by multiple platform stacks

## What Would Use It

- `platform-v2/connectivity`
- `platform-v2/management`
- `platform-v2/identity`

## When Not To Use It

If a capability clearly belongs to networking, management, or identity, it
should usually stay in that stack.

This layer should remain small so it does not become a catch-all bucket for
unrelated resources.
