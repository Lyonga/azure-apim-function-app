# Dev Platform V2 Bootstrap

## Purpose

This directory is reserved for an optional environment bootstrap root that
would run before the active `connectivity`, `management`, and `identity`
stacks.

It is where you would place environment-scoped prerequisites that are too early
or too foundational to live naturally in one of the platform service stacks.

## Current State

- placeholder directory
- no active Terraform root in this directory today

## Intended Responsibilities

If you choose to activate this layer later, good candidates include:

- provider-registration or subscription-readiness checks
- precreated platform resource groups
- environment-shared bootstrap storage or secrets handoff
- early objects that multiple platform-v2 roots depend on at once

## Relationship To Other Stacks

- would run before `platform-v2/connectivity`
- would run before `platform-v2/management`
- would run before `platform-v2/identity`

## Best-Practice Context

Keep this layer small. If a capability is clearly networking, management, or
identity, it should usually live in the corresponding platform-v2 stack instead
of being promoted into bootstrap.
