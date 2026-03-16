# V2 Enterprise Pattern

This document describes the active v2 deployment pattern in this repo. It is the focused architecture guide for:

- `global/*`
- `stacks/<env>/platform-v2/*`
- `stacks/<env>/workload-v2/*`

It does not describe the deprecated legacy roots under `stacks/dev/platform` or `stacks/dev/workloads`.

## Purpose

The v2 model separates the Azure estate by operating model and blast radius:

- company-wide control plane in `global/*`
- environment-scoped platform services in `platform-v2/*`
- application landing zones in `workload-v2/*`

That split follows the Azure Landing Zone guidance to organize subscriptions and governance centrally, then let platform and application landing zones consume those controls at lower scope.[1][2][3][4][5]

## Design Principles

The v2 pattern in this repo is built on these principles:

1. Governance first. Management groups, policy, and high-scope RBAC are created before platform and workload resources.[1][5][6]
2. Platform and workload isolation. Shared platform concerns live outside workload stacks, even in this dev demo where several platform capabilities are intentionally collapsed into one platform subscription.[1][2][4]
3. Private-by-default services. Networking, storage, Key Vault, App Configuration, Service Bus, and SQL are designed around private endpoints, central Private DNS, and explicit VNet integration.[3][7][8]
4. Identity over secrets. Managed identities and RBAC are preferred over embedded secrets and long-lived credentials.[2][9]
5. State by blast radius. Each root has its own backend key and its own deployment workflow boundary.
6. Explicit subscription targeting. Active roots keep an explicit `subscription_id` and validate it against the central subscription catalog.
7. Platform-owned prerequisites. Resource provider registration and the shared backend are treated as platform prerequisites, not ad hoc side effects during workload deployment.

## Stack Model

The active v2 estate has three layers.

### 1. Global Control Plane

These roots establish tenant-level and management-group-level governance.

| Stack | Scope | What it owns | Why it exists |
| --- | --- | --- | --- |
| [`global/subscriptions`](./global/subscriptions) | catalog and subscription metadata | approved subscription inventory, management-group placement metadata, stack validation inputs | keeps subscription ownership and placement explicit instead of hidden in stack-local variables |
| [`global/management-groups`](./global/management-groups) | tenant and management-group scope | management-group hierarchy and subscription associations | aligns resource organization with Azure Landing Zone guidance for policy and RBAC inheritance.[1][5] |
| [`global/policy`](./global/policy) | management-group scope | shared policy definitions, initiatives, and assignments | applies governance from higher scopes and assigns it at the child scopes that consume it.[5][6] |
| [`global/role-assignments`](./global/role-assignments) | management-group scope | high-scope RBAC for platform administration | keeps tenant and management-group access separate from workload RBAC |

### 2. Environment-Scoped Platform Services

These roots create reusable services that workloads consume.

| Stack | Scope | What it owns | Typical consumers |
| --- | --- | --- | --- |
| [`stacks/dev/platform-v2/connectivity`](./stacks/dev/platform-v2/connectivity) | platform subscription | hub VNet, central Private DNS zones, DNS links | identity and workload spokes |
| [`stacks/dev/platform-v2/management`](./stacks/dev/platform-v2/management) | platform subscription | Log Analytics, diagnostics archive storage, action group, Recovery Services vault, subscription activity log baseline | platform and workload diagnostics |
| [`stacks/dev/platform-v2/identity`](./stacks/dev/platform-v2/identity) | platform subscription | identity spoke VNet, shared Key Vault, shared user-assigned identities, shared CMK, private endpoint, diagnostics | platform automation and workloads that use shared identities/keys |

### 3. Application Landing Zones

These roots create workload-specific resources inside workload subscriptions.

| Stack | Scope | What it owns | Depends on |
| --- | --- | --- | --- |
| [`stacks/dev/workload-v2/finserv-api`](./stacks/dev/workload-v2/finserv-api) | workload subscription | workload RG, spoke VNet, NSGs, peering, storage, Key Vault, App Insights, private endpoints, optional Service Bus/App Configuration/SQL/ACR/APIM/Function App, optional demo VM | connectivity, management, identity, global governance |

## What Each V2 Stack Does

### `platform-v2/connectivity`

This stack is the shared network foundation for the platform subscription.

In this repo it currently creates:

- the hub resource group
- the hub VNet
- the central Private DNS zones
- the initial hub VNet links to those DNS zones

Why it exists:

- Workloads and shared services should not each create their own Private DNS estate.
- Centralizing hub networking and DNS reduces duplication and makes private endpoint name resolution predictable at scale.[3][7]
- Shared connectivity belongs in a platform boundary, not in an application landing zone.[3]

Best-practice alignment:

- hub/spoke topology is a standard Azure Landing Zone pattern for shared connectivity.[3]
- private endpoint DNS should be managed consistently and centrally, especially when multiple services share the same zones.[7]

### `platform-v2/management`

This stack is the shared observability and recovery layer for the platform subscription.

In this repo it currently creates:

- a Log Analytics workspace
- a diagnostics archive storage account
- an action group
- a Recovery Services vault
- a baseline for subscription activity logs

Why it exists:

- Monitoring, alerting, archive storage, and subscription activity logging are platform capabilities, not app-specific concerns.
- Workloads should send telemetry into a central management plane rather than each team inventing its own logging model.[4][10]

Best-practice alignment:

- the Azure Landing Zone management guidance treats monitoring and management as foundational platform capabilities.[4][10]
- separating management services from application landing zones makes retention, alerting, and diagnostics easier to standardize.

### `platform-v2/identity`

This stack is the shared identity-services layer for the platform subscription.

In this repo it currently creates:

- an identity spoke VNet
- two identity-focused subnets: shared services and private endpoints
- peering from the identity spoke back to the hub
- shared Private DNS links into the connectivity plane
- a shared Key Vault
- shared user-assigned managed identities
- a shared customer-managed key
- a private endpoint for the Key Vault
- diagnostics for the shared Key Vault

Why it exists:

- Shared managed identities and shared encryption keys should be owned by a platform identity boundary, then consumed by workloads through RBAC.
- Identity services are a platform responsibility in Azure Landing Zones, and the identity landing zone is expected to connect back to hub networking.[2]

Best-practice alignment:

- Azure Landing Zone guidance explicitly treats identity as a core platform responsibility.[2]
- use user-assigned managed identities for shared reusable automation and service access patterns; use system-assigned identities for single-resource identities where lifecycle coupling is useful.[9]
- keep role assignments for application landing zones at subscription or resource-group scope rather than mixing them with policy at management-group scope.[2]

### `workload-v2/finserv-api`

This stack is the application landing zone for the sample workload.

In this repo it currently composes:

- a workload resource group
- a workload spoke VNet
- dedicated subnets for `app`, `integration`, `data`, and `private-endpoints`
- dedicated NSGs per subnet role
- VNet peering back to the hub
- links into the central Private DNS zones
- Application Insights connected to the shared workspace
- workload storage account with private endpoints
- workload Key Vault with private endpoint
- optional App Configuration with private endpoint
- optional Service Bus with private endpoint
- optional SQL with private endpoint
- optional ACR
- optional Function App on a delegated integration subnet
- optional APIM
- optional low-cost demo Windows VM for validation of the private networking and managed identity pattern

Why it exists:

- application landing zones should own workload-local resources and consume shared platform services instead of recreating them.[1][2][3]
- the workload retains autonomy at lower scope while inheriting governance from management groups and policy assignments.[5][6]

Best-practice alignment:

- the Function App integration subnet is delegated to `Microsoft.Web/serverFarms`, which is required for App Service regional VNet integration.[8][11]
- private endpoints and central Private DNS are used for storage, Key Vault, Service Bus, App Configuration, and SQL to support private-by-default access.[7]
- the workload uses managed identity and RBAC to access Key Vault and storage instead of embedding secrets.[2][9]

## Why The Layers Are Split This Way

The split is deliberate.

### Control plane vs platform vs workload

- `global/*` changes affect tenant-wide behavior and inheritance.
- `platform-v2/*` changes affect many workloads but usually stay inside a platform subscription boundary.
- `workload-v2/*` changes affect one application landing zone.

That separation reduces blast radius, reduces state contention, and makes approvals easier:

- governance changes can be reviewed differently from app releases
- shared networking can be updated without touching workload state
- workload teams can iterate without holding ownership of management-group or policy resources

### Definitions at higher scope, assignments at lower scope

The v2 policy model follows Azure Policy guidance:

- create reusable definitions and initiatives at a higher scope
- assign them to the child scope that should inherit them

That is why this repo keeps shared policy definitions in `global/policy` and assigns initiatives at management-group scope rather than burying policy inside each workload stack.[5][6]

### Shared DNS and peering in the platform plane

Private endpoint DNS only scales cleanly if the DNS zones are shared and linked consistently. Centralizing Private DNS in `platform-v2/connectivity` avoids each workload creating its own disconnected name-resolution island.[7]

### Shared identity and keys in the identity plane

User-assigned managed identities and shared CMKs are long-lived platform assets. Keeping them in `platform-v2/identity` makes their lifecycle independent from any single app and matches the Azure Landing Zone identity operating model.[2][9]

## Deployment Order

Apply the active v2 path in this order:

1. [`global/subscriptions`](./global/subscriptions)
2. [`global/management-groups`](./global/management-groups)
3. [`global/policy`](./global/policy)
4. [`global/role-assignments`](./global/role-assignments)
5. [`stacks/dev/platform-v2/connectivity`](./stacks/dev/platform-v2/connectivity)
6. [`stacks/dev/platform-v2/management`](./stacks/dev/platform-v2/management)
7. [`stacks/dev/platform-v2/identity`](./stacks/dev/platform-v2/identity)
8. [`stacks/dev/workload-v2/finserv-api`](./stacks/dev/workload-v2/finserv-api)

Why the order matters:

- downstream stacks consume upstream remote-state outputs
- governance must exist before platform and workload landing zones inherit it
- connectivity and DNS must exist before private endpoints and private DNS links
- management must exist before diagnostics wiring
- identity must exist before workloads consume shared identities and keys

## Best Practices Explicitly Applied In V2

### 1. Management groups and policy as code

The v2 model uses management groups, initiatives, and assignments as first-class Terraform roots. That follows Microsoft guidance to organize subscriptions through management groups and manage policy resources as code.[1][5]

### 2. Subscription isolation by role

The active dev demo uses:

- one platform subscription for connectivity, management, and identity
- one separate workload subscription for the application landing zone

That is already better than a monolithic single-subscription demo. The fuller enterprise target is to separate connectivity, management, identity, and workload subscriptions even further when the estate size justifies it.[1][2][3][4]

### 3. Central monitoring plane

The v2 model routes shared monitoring capabilities through the management stack. That follows Azure Landing Zone guidance to standardize management and monitoring as platform capabilities rather than leaving them entirely to each workload team.[4][10]

### 4. Private-by-default service access

The v2 stacks use private endpoints, central Private DNS, and VNet integration where services support it. This is aligned with Microsoft guidance on Private Link DNS integration at scale and App Service networking patterns.[7][8][11]

### 5. Managed identities over application secrets

The v2 pattern uses user-assigned and system-assigned managed identities plus RBAC. That reduces secret sprawl and makes shared access patterns reusable across resources.[2][9]

### 6. Explicit subnet purpose

The workload spoke does not use generic subnets. Instead it separates:

- `app`
- `integration`
- `data`
- `private-endpoints`
- optional `apim`

This keeps service requirements clear, especially where Azure requires dedicated delegated subnets for App Service integration.[8][11]

### 7. Provider registration as a platform prerequisite

Active roots set `skip_provider_registration = true`. That means subscriptions must be registered for the required namespaces ahead of time. This is the safer enterprise pattern because deployment identities do not need broad `*/register/action` permissions.

### 8. OIDC and Azure AD-backed backend auth

The workflows use OIDC for Azure authentication and the remote state uses Azure AD auth. That avoids long-lived credentials in CI and matches the recommended direction for modern Azure automation.

## Current Demo Deviations From The Enterprise Target

This repo intentionally contains a few dev/demo concessions:

- `dev` is the only active validated environment
- `test` and `prod` are scaffolds, not active promoted estates
- the shared backend is precreated outside this repo
- the dev platform plane collapses connectivity, management, and identity into one shared platform subscription
- the dev workload stack allows lower-cost toggles, including a demo Windows VM path, to validate networking and identity patterns in a personal subscription
- GitHub-hosted runners required pragmatic network accommodations for private-only services; the stricter enterprise target would be a self-hosted runner inside the private network boundary

These deviations are acceptable for demo validation, but they are not the final enterprise target.

## Recommended Reading

Use these official Microsoft references when reviewing or extending the v2 pattern:

1. Azure Landing Zone overview: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/>
2. Management groups design area: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups>
3. Network topology and connectivity design area: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity>
4. Identity and access design area: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access>
5. Identity in application landing zones: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access-landing-zones>
6. Azure Policy overview: <https://learn.microsoft.com/en-us/azure/governance/policy/overview>
7. Azure Policy definition scope basics: <https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure-basics>
8. Private Link and DNS integration at scale: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale>
9. App Service VNet integration: <https://learn.microsoft.com/en-us/azure/app-service/configure-vnet-integration-enable>
10. App Service VNet integration overview: <https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration>
11. Managed identity best-practice recommendations: <https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations>
12. Landing zone management and monitoring: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/management-monitor>

