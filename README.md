# Azure Enterprise Terraform Blueprint

The root Terraform monolith has been removed. Infrastructure now lives under [`azure-enterprise-terraform/`](./azure-enterprise-terraform), organized as a company-wide control plane plus environment-scoped platform and workload stacks:

- `terraform/global/subscriptions`
- `terraform/global/management-groups`
- `terraform/global/policy`
- `terraform/global/role-assignments`
- `terraform/stacks/dev/platform-v2/connectivity`
- `terraform/stacks/dev/platform-v2/management`
- `terraform/stacks/dev/platform-v2/identity`
- `terraform/stacks/dev/workload-v2/finserv-api`
- `terraform/stacks/test/...` placeholder v2 environment scaffolding
- `terraform/stacks/prod/...` placeholder v2 environment scaffolding

Current pattern status:

- management groups, policy, and RBAC are centralized under `terraform/global`
- subscription inventory and placement inputs are centralized in `terraform/global/subscriptions`
- the shared Terraform backend is a precreated platform prerequisite, and active platform layers are `connectivity`, `management`, and `identity`
- active dev v2 stacks are now subscription-aware instead of only state-separated
- active dev v2 stacks keep explicit root `subscription_id` values and validate them against the central global `subscriptions` catalog
- hub-spoke, peering, private DNS, and private endpoints are implemented for the active path
- workloads consume shared platform state and shared identity/CMK services by default
- the repo is still a `dev`-first blueprint; `test` and `prod` exist as placeholders for enterprise review but are not active deployable environments yet

The application assets remain in this repo:

- `api-spec.yml` for the sample APIM import
- `func/` for the sample Python Azure Function payload

Start with [`azure-enterprise-terraform/README.md`](./azure-enterprise-terraform/README.md).

For the landing-zone assessment, remediation-vs-rebuild guidance, and a review of how this repo aligns with Azure Landing Zone, RBAC, policy, state, and OIDC best practices, see [`azure-enterprise-terraform/RECOMMENDATIONS.md`](./azure-enterprise-terraform/RECOMMENDATIONS.md).
