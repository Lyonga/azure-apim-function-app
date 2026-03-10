# Azure Enterprise Terraform Blueprint

The root Terraform monolith has been removed. Infrastructure now lives under [`azure-enterprise-terraform/`](./azure-enterprise-terraform), organized as landing-zone style root stacks:

- `terraform/stacks/dev/platform-v2/bootstrap`
- `terraform/stacks/dev/platform-v2/governance`
- `terraform/stacks/dev/platform-v2/connectivity`
- `terraform/stacks/dev/platform-v2/management`
- `terraform/stacks/dev/workload-v2/finserv-api`

The application assets remain in this repo:

- `api-spec.yml` for the sample APIM import
- `func/` for the sample Python Azure Function payload

Start with [`azure-enterprise-terraform/README.md`](./azure-enterprise-terraform/README.md).

For the landing-zone assessment, remediation-vs-rebuild guidance, and a review of how this repo aligns with Azure Landing Zone, RBAC, policy, state, and OIDC best practices, see [`azure-enterprise-terraform/RECOMMENDATIONS.md`](./azure-enterprise-terraform/RECOMMENDATIONS.md).
