# Azure Enterprise Terraform Blueprint

The root Terraform monolith has been removed. Infrastructure now lives under [`azure-enterprise-terraform/`](./azure-enterprise-terraform), organized as landing-zone style root stacks:

- `terraform/stacks/dev/platform-v2/bootstrap`
- `terraform/stacks/dev/platform-v2/subscriptions`
- `terraform/stacks/dev/platform-v2/governance`
- `terraform/stacks/dev/platform-v2/connectivity`
- `terraform/stacks/dev/platform-v2/management`
- `terraform/stacks/dev/platform-v2/identity`
- `terraform/stacks/dev/workload-v2/finserv-api`

Current pattern status:

- management groups, policy, and RBAC are centralized in `platform-v2/governance`
- subscription inventory and placement inputs are centralized in `platform-v2/subscriptions`
- platform layers are split into `bootstrap`, `subscriptions`, `governance`, `connectivity`, `management`, and `identity`
- active dev v2 stacks are now subscription-aware instead of only state-separated
- active dev v2 stacks keep explicit root `subscription_id` values and validate them against the central `subscriptions` catalog
- hub-spoke, peering, private DNS, and private endpoints are implemented for the active path
- workloads consume shared platform state and shared identity/CMK services by default
- the repo is still a `dev`-first blueprint, not yet a full multi-environment landing zone estate

The application assets remain in this repo:

- `api-spec.yml` for the sample APIM import
- `func/` for the sample Python Azure Function payload

Start with [`azure-enterprise-terraform/README.md`](./azure-enterprise-terraform/README.md).

For the landing-zone assessment, remediation-vs-rebuild guidance, and a review of how this repo aligns with Azure Landing Zone, RBAC, policy, state, and OIDC best practices, see [`azure-enterprise-terraform/RECOMMENDATIONS.md`](./azure-enterprise-terraform/RECOMMENDATIONS.md).
