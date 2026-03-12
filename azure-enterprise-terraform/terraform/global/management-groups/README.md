This root is the active company-wide management group hierarchy for the demo
landing zone.

It reads subscription placement from `terraform/global/subscriptions` and
creates:

- platform
- connectivity
- management
- identity
- security
- landing-zones
- prod
- nonprod
- sandbox
- decommissioned

In the active dev demo, only the shared platform subscription and the
nonprod workload subscription are associated. Connectivity, management, and
identity remain separate Terraform stacks but intentionally deploy into the
shared platform subscription.
