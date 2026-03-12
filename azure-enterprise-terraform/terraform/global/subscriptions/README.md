# Global Subscriptions

This root is the company-wide subscription catalog for the demo landing zone.

In the active demo pattern it does not vend subscriptions. It records which
existing subscription is used for each logical landing-zone role and exposes
that mapping through remote state for:

- `global/management-groups`
- environment platform stacks that validate their explicit `subscription_id`
- workload stacks that validate their target workload subscription

For the current dev demo, the catalog intentionally keeps only:

- `platform`
- `nonprod_workload`

The connectivity, management, and identity stacks deploy into the shared
platform subscription in this demo, so they validate against the `platform`
catalog entry instead of separate subscriptions.
