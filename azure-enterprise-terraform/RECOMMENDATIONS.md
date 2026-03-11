# Azure Landing Zone Recommendations

This document captures the operating-model guidance behind the Terraform blueprint in this repo. It is intended to answer two questions:

1. should an Azure estate be remediated in place or rebuilt in a controlled way;
2. how closely does this repo already follow that model.

Use this together with [`README.md`](./README.md), which explains how to run the stacks.

## Recommended Decision Framework

Assess an Azure Terraform estate through four lenses before choosing remediation or rebuild.

### 1. Platform architecture

Check whether the tenant is already organized into a real Azure Landing Zone hierarchy:

- management groups;
- separate platform and workload subscriptions;
- central connectivity, management, and shared-services boundaries;
- workload isolation by environment or application family.

If everything is mixed into one or two subscriptions, the platform layer is usually cheaper to rebuild than normalize in place.

### 2. Terraform estate quality

Check for:

- remote state in Azure Storage with locking;
- clear state boundaries by blast radius;
- pinned providers and reusable modules;
- environment isolation;
- composition-based stacks instead of copy-paste roots;
- predictable plan and apply behavior.

If the codebase is mostly duplicated roots with shared state and inconsistent auth, rebuild the platform baseline and migrate workloads incrementally.

### 3. Azure governance alignment

Check whether these are managed as first-class IaC concerns:

- management groups;
- policy definitions, assignments, and exemptions;
- RBAC assignments at the correct scope;
- shared tagging and naming standards;
- workload restrictions such as public IP, region, and diagnostics controls.

If governance is still mostly manual, the code may deploy but the platform is still operationally non-compliant.

### 4. Operational recoverability

Check whether the team can:

- import existing resources safely;
- detect drift on a schedule;
- handle stale state locks;
- promote reviewed plans across environments;
- separate governance changes from workload changes.

If none of that is reliable, the estate is in platform debt and a controlled rebuild is lower risk.

## Recommended Delivery Pattern

For most enterprise Azure estates, the safest pattern is:

- rebuild the platform baseline;
- remediate and migrate workloads incrementally.

That usually means:

- rebuild management groups, policy, RBAC, state, connectivity, and management stacks;
- keep workloads moving through import or selective recreation against the new baseline.

## Target Azure Landing Zone Pattern

The desired landing-zone shape is:

- management-group hierarchy for platform and workloads;
- connectivity subscription for hub networking, firewall, DNS, and shared routes;
- management subscription for monitoring, diagnostics, and security tooling;
- optional identity or shared-services subscription;
- workload subscriptions per application domain or environment;
- separate pipelines and identities for governance and workloads.

For Terraform, prefer:

- Azure Landing Zone accelerator patterns where applicable;
- Azure Verified Modules where possible for core Azure resources;
- small composition roots for governance, connectivity, management, and workloads;
- one backend key per stack.

## Current Pattern Status

The active v2 path in this repo now maps to that target pattern as follows:

- implemented: management-group hierarchy and subscription placement associations in governance
- implemented: a dedicated `subscriptions` root for subscription inventory and optional vending
- implemented: separate platform roots for `bootstrap`, `subscriptions`, `governance`, `connectivity`, `management`, and `identity`
- implemented: explicit per-stack subscription targeting for active v2 roots
- implemented: centralized backend state in a separate platform subscription using Azure AD-backed backend auth
- implemented: hub-spoke networking, Private DNS, and workload peering
- implemented: shared identity and shared CMK services in a dedicated identity stack
- implemented: OIDC-ready plan and drift workflows for the active path
- partial: governance policy set is still narrow relative to a full ALZ enterprise baseline
- partial: active rollout is still `dev` only
- partial: connectivity is still lighter than a full enterprise transit estate with VPN/ExpressRoute/firewall standards

## Azure Operating Model Requirements

### State and backend

Use Azure Storage for remote state. Keep backend resources in a platform-owned scope and enable:

- blob versioning;
- blob soft delete;
- container soft delete;
- TLS 1.2 minimum;
- RBAC-controlled access;
- state locking via the backend.

Recommended state boundaries:

- governance and management groups;
- policy definitions and assignments;
- connectivity;
- management and observability;
- one workload or workload family per state.

### Locking and recovery

- do not use `-lock=false` as normal practice;
- serialize applies per stack;
- treat `terraform force-unlock` as break-glass only after confirming the lock is stale;
- keep a documented stale-lock runbook.

### Imports and drift

Imports should be structured, not ad hoc:

- map Azure resource IDs to target module addresses;
- stabilize the module contract first;
- import;
- run plan immediately after import;
- resolve ownership drift before apply.

Drift detection should be scheduled and read-only. In Azure, common drift sources are portal edits, policy remediations, diagnostic settings, RBAC changes, and private-endpoint or DNS changes by other teams.

### CI/CD and identities

Recommended pattern:

- PR: `fmt`, `validate`, lint, security scan, plan;
- reviewed plan artifact;
- manual or approved apply in the target environment;
- OIDC for active pipelines;
- no long-lived secrets for the new platform path.

Keep governance pipelines separate from workload pipelines. Do not allow every workload pipeline to assign broad RBAC or policy at high scope.

## How This Repo Implements The Pattern

The current repo already follows a large portion of that model.

### Platform layering

The active deployment model is split into separate root stacks:

- [`terraform/stacks/dev/platform-v2/bootstrap`](./terraform/stacks/dev/platform-v2/bootstrap)
- [`terraform/stacks/dev/platform-v2/subscriptions`](./terraform/stacks/dev/platform-v2/subscriptions)
- [`terraform/stacks/dev/platform-v2/governance`](./terraform/stacks/dev/platform-v2/governance)
- [`terraform/stacks/dev/platform-v2/connectivity`](./terraform/stacks/dev/platform-v2/connectivity)
- [`terraform/stacks/dev/platform-v2/management`](./terraform/stacks/dev/platform-v2/management)
- [`terraform/stacks/dev/platform-v2/identity`](./terraform/stacks/dev/platform-v2/identity)
- [`terraform/stacks/dev/workload-v2/finserv-api`](./terraform/stacks/dev/workload-v2/finserv-api)

This is the right operating-model split for Azure:

- bootstrap owns backend state infrastructure;
- subscriptions owns subscription inventory and optional vending;
- governance owns management groups, policy, RBAC, and subscription associations;
- connectivity owns hub networking and private DNS;
- management owns logging, activity log export, and recovery;
- identity owns shared managed identities, shared encryption keys, and identity-adjacent shared services;
- workloads consume shared state outputs and stay thinner.

### Subscription isolation

The active v2 roots now declare `subscription_id` explicitly at the root provider level. This means the blueprint is no longer only separated by state files; it is separated by deployment subscription as well.

That is the right baseline for an enterprise Azure landing-zone implementation when each platform layer is deployed from a separate Terraform root.

### Governance as code

The active governance stack already creates:

- management groups through [`terraform/modules/management_groups`](./terraform/modules/management_groups);
- policy definitions and a policy set in [`terraform/stacks/dev/platform-v2/governance/main.tf`](./terraform/stacks/dev/platform-v2/governance/main.tf);
- management-group policy assignments;
- role assignments through [`terraform/modules/role-assignments`](./terraform/modules/role-assignments).

That is materially better than a resource-group-only policy model.

### State boundaries and backend usage

The active v2 stacks use the AzureRM backend pattern documented in [`README.md`](./README.md), and the bootstrap stack provisions the backend storage in [`terraform/stacks/dev/platform-v2/bootstrap/main.tf`](./terraform/stacks/dev/platform-v2/bootstrap/main.tf).

The repo also documents:

- per-stack backend keys;
- locking and lease handling;
- concurrency controls;
- drift detection as a scheduled plan stream.

### Hub-spoke and private connectivity

The active v2 path uses:

- hub networking in [`terraform/stacks/dev/platform-v2/connectivity/main.tf`](./terraform/stacks/dev/platform-v2/connectivity/main.tf);
- spoke networking and peering in [`terraform/stacks/dev/workload-v2/finserv-api/main.tf`](./terraform/stacks/dev/workload-v2/finserv-api/main.tf);
- central Private DNS plus per-spoke links;
- dedicated private endpoints for Key Vault, Storage, SQL, Service Bus, App Configuration, and optionally Function App.

That is consistent with an Azure Landing Zone hub-spoke model rather than a flat VNet approach.

### Shared identity services

The repo now includes a dedicated identity layer in [`terraform/stacks/dev/platform-v2/identity`](./terraform/stacks/dev/platform-v2/identity) that provides:

- a separate identity subscription target;
- a shared-services VNet;
- hub peering and Private DNS linking;
- a premium Key Vault;
- shared user-assigned identities;
- a shared HSM-backed CMK;
- diagnostics into the management workspace.

The sample workload consumes that shared identity and CMK path by default instead of recreating those encryption primitives inside the workload subscription.

### Security and workload composition

The v2 workload root demonstrates the right general direction:

- private-by-default storage and Key Vault;
- user-assigned identity;
- centralized monitoring workspace consumption;
- diagnostics modules;
- private endpoints and DNS integration;
- API Management on an internal subnet;
- SQL auditing and security alert policies enabled in composition.

### CI/CD and drift

The repo already has:

- PR and push validation in [`../.github/workflows/terraform-ci.yml`](../.github/workflows/terraform-ci.yml);
- reviewed-plan workflow in [`../.github/workflows/terraform-plan-apply.yml`](../.github/workflows/terraform-plan-apply.yml);
- scheduled drift detection in [`../.github/workflows/terraform-drift.yml`](../.github/workflows/terraform-drift.yml);
- a manual-only legacy workflow in [`../.github/workflows/test-infra.yaml`](../.github/workflows/test-infra.yaml), kept separate so it does not pollute the active v2 CI signal.

## Current Alignment Review

The repo mostly follows the intended pattern, but it is not fully at enterprise landing-zone maturity yet.

### Areas that are already strong

- Separate platform and workload roots are in place.
- Governance, networking, management, and workloads are separated by state.
- Active v2 roots are now explicitly separated by subscription target as well.
- The active workload path uses shared-state consumption rather than a monolith.
- Shared identity and CMK services are centralized in a dedicated identity stack.
- Private endpoints, Private DNS, and hub-spoke peering are modeled.
- Checkov, validation, and drift detection are built into CI.
- The new pipeline path is designed for OIDC rather than long-lived secrets.

### Remaining gaps to close

#### 1. AVM / accelerator alignment is still aspirational

The repo uses custom modules under [`terraform/modules`](./terraform/modules) rather than Azure Verified Modules or a direct Azure Landing Zone accelerator implementation. The current structure is compatible with that target, but it is not there yet.

Recommendation:

- adopt AVM selectively for shared platform resources first;
- keep custom composition roots, but reduce custom resource modules where an AVM equivalent exists.

#### 2. Active deployment is only `dev`

The active v2 model currently exists under [`terraform/stacks/dev`](./terraform/stacks/dev). That is enough for proving the operating model, but not enough to demonstrate a full promotion path across nonprod and prod landing zones.

Recommendation:

- add explicit nonprod and prod v2 stacks or environment composition;
- keep backend keys, identities, and approvals separate per environment.

#### 3. Governance baseline is still lightweight

[`terraform/stacks/dev/platform-v2/governance/main.tf`](./terraform/stacks/dev/platform-v2/governance/main.tf) currently defines:

- allowed locations;
- required tags;
- deny public IP creation.

That is a useful start, but it is not yet a mature enterprise governance baseline.

Recommendation:

- add policy exemptions as code;
- add diagnostics and logging `deployIfNotExists` or equivalent controls;
- add stronger identity, data, and network baselines;
- expand role separation for platform, security, and workload pipelines.

#### 4. Some reusable modules still depend on caller-side exceptions

Several shared modules intentionally carry Checkov exceptions because the private endpoint, CMK, or service-specific compatibility behavior is owned by the caller:

- [`terraform/modules/storage/main.tf`](./terraform/modules/storage/main.tf)
- [`terraform/modules/state-storage/main.tf`](./terraform/modules/state-storage/main.tf)
- [`terraform/modules/keyvault/main.tf`](./terraform/modules/keyvault/main.tf)
- [`terraform/modules/sql-database/main.tf`](./terraform/modules/sql-database/main.tf)

This is acceptable for a reusable composition model, but it means the module alone is not always sufficient proof of compliance.

Recommendation:

- keep documenting which controls are module-owned versus stack-owned;
- where possible, expose stricter secure defaults and reduce the need for skip annotations.

#### 5. Legacy stacks still exist and should remain temporary

The repo still retains legacy paths under:

- [`terraform/stacks/dev/platform`](./terraform/stacks/dev/platform)
- [`terraform/stacks/dev/workloads`](./terraform/stacks/dev/workloads)
- [`terraform/stacks/prod`](./terraform/stacks/prod)
- [`terraform/global`](./terraform/global)

Those are useful for migration and reference, but they are not the target operating model.

Recommendation:

- stop expanding legacy stacks;
- complete output migration and imports into v2;
- archive or delete legacy stacks once state migration is complete.

#### 6. OIDC requires explicit GitHub Environment and Entra ID setup

The new workflows are designed for OIDC, but they depend on:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

being available at the repository or GitHub Environment scope, and on the target Entra application having the correct federated credential configured for the repo and workflow subject.

Recommendation:

- keep OIDC for active stacks;
- keep service-principal secret auth only for the legacy workflow until it is retired;
- document environment-scoped identity prerequisites alongside each deployment workflow.

#### 7. Backend RBAC is now a hard prerequisite

Because the active v2 backends use `use_azuread_auth = true`, the deployment identity must have Blob data-plane access to the backend storage account or container.

Recommendation:

- grant `Storage Blob Data Contributor` at the backend storage account or container scope;
- keep backend state in a platform-owned subscription separate from workload subscriptions;
- document backend subscription ownership and RBAC alongside the OIDC setup.

## Recommended Next Steps

### First priority

- stabilize OIDC for `terraform-plan-apply.yml` and `terraform-drift.yml`;
- keep `test-infra.yaml` manual-only and legacy-only;
- finish migrating any remaining live workload dependencies into v2.

### Second priority

- add nonprod and prod v2 stack structure;
- expand governance with exemptions and deploy-time compliance controls;
- reduce or eliminate remaining module-level Checkov exceptions where practical.

### Third priority

- adopt AVM selectively for shared platform resources;
- add `tflint`, `terraform test`, and cross-stack contract tests;
- retire legacy stacks after imports and cutover are complete.

## Official References

- Azure Terraform landing zones accelerator:
  - https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/deploy-landing-zones-with-terraform
- Azure landing zone conceptual guidance:
  - https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/
- Azure management groups:
  - https://learn.microsoft.com/en-us/azure/governance/management-groups/overview
- Azure Policy overview:
  - https://learn.microsoft.com/en-us/azure/governance/policy/overview
- Azure Policy exemptions:
  - https://learn.microsoft.com/en-us/azure/governance/policy/concepts/exemption-structure
- Azure RBAC overview:
  - https://learn.microsoft.com/en-us/azure/role-based-access-control/overview
- Azure built-in roles:
  - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
- Terraform remote state in Azure Storage:
  - https://learn.microsoft.com/en-us/azure/developer/terraform/get-started/store-state-in-azure-storage
- Terraform state locking:
  - https://developer.hashicorp.com/terraform/language/state/locking
- Terraform `force-unlock`:
  - https://developer.hashicorp.com/terraform/cli/commands/force-unlock
- GitHub OIDC with Azure:
  - https://docs.github.com/en/actions/how-tos/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure
- Azure hub-and-spoke reference:
  - https://learn.microsoft.com/en-us/azure/developer/terraform/azurerm/hub-spoke-introduction
