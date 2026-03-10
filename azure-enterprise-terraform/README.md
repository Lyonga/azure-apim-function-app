# Azure Landing Zone Terraform Blueprint

This directory is the authoritative infrastructure entry point for the repo. It replaces the old single-root demo with a security-first, landing-zone-oriented Terraform layout intended for financial-services workloads.

For the assessment framework, remediation-vs-rebuild guidance, official Azure and Terraform references, and a review of how this repo currently aligns with those patterns, see [`RECOMMENDATIONS.md`](./RECOMMENDATIONS.md).

## Goals

- Split infrastructure by blast radius and operating model, not by convenience.
- Keep security and governance above workload speed.
- Make local testing possible in a personal subscription while preserving patterns that scale to a client estate.
- Use remote state, management groups, RBAC, policy, hub-spoke networking, private DNS, diagnostics, drift detection, and CI scanning as first-class concerns.

## Repo Layout

```text
azure-enterprise-terraform/
  terraform/
    modules/
      action-group/
      app-configuration/
      apim/
      azuredevops_repo/
      container_registry/
      diagnostics-1/
      function_app/
      keyvault/
      log-analytics/
      management_groups/
      monitoring-baseline/
      network/
      platform-tags/
      private-dns/
      private-endpoint/
      recovery-services-vault/
      resource_group/
      role-assignments/
      service-bus/
      sql-database/
      state-storage/
      storage/
      user-assigned-identity/
      vnet-hub/
      vnet-peering/
      vnet-spoke/
    stacks/
      dev/
        platform-v2/
          bootstrap/
          governance/
          connectivity/
          management/
        workload-v2/
          finserv-api/
```

`terraform/stacks/dev/platform-v2` and `terraform/stacks/dev/workload-v2` are the active deployment model.

Legacy folders under `terraform/stacks/dev/platform`, `terraform/stacks/dev/workloads`, `terraform/stacks/prod/*`, and `terraform/global/*` are retained only as reference while this blueprint is adopted. Do not extend them.

## Deployment Order

Apply stacks in this order:

1. `terraform/stacks/dev/platform-v2/bootstrap`
2. `terraform/stacks/dev/platform-v2/governance`
3. `terraform/stacks/dev/platform-v2/connectivity`
4. `terraform/stacks/dev/platform-v2/management`
5. `terraform/stacks/dev/workload-v2/finserv-api`

This order matters because:

- the backend must exist before remote state can be used;
- governance should exist before platform and workloads are deployed;
- connectivity and private DNS are shared dependencies for private endpoints;
- management provides central logging and recovery services used by workloads.

## Stack Purpose

### `platform-v2/bootstrap`

Creates the Azure Storage backend used by all other stacks.

Key design choices:

- blob versioning enabled
- blob and container soft delete enabled
- infrastructure encryption enabled
- separate backend key per stack
- Azure AD auth supported via `use_azuread_auth = true`
- optional network rules, but public access can remain on when using GitHub-hosted runners

### `platform-v2/governance`

Creates:

- management group hierarchy
- subscription placement
- sample landing-zone baseline initiative
- sample RBAC assignments for platform and workload deployers

The baseline currently includes:

- allowed locations
- required tags
- deny public IP creation

This is intentionally opinionated and should be extended with your client-specific controls, exemptions, and `deployIfNotExists` policies for diagnostics.

### `platform-v2/connectivity`

Creates:

- hub virtual network
- shared hub subnets
- optional Azure Firewall
- central Private DNS zones
- hub VNet links to those Private DNS zones

This is where you swap in a third-party firewall or DNS design if the client standard is Palo Alto, Cisco Umbrella, or another centralized service. The module structure stays valid even if the egress implementation changes.

### `platform-v2/management`

Creates:

- Log Analytics workspace
- diagnostics archive storage account
- action group
- Recovery Services Vault
- subscription activity log export baseline

This is the starting point for Sentinel, Defender integrations, alert routing, and operational observability standardization.

### `workload-v2/finserv-api`

Creates a sample workload stack that demonstrates:

- workload resource group
- spoke VNet
- restrictive NSG defaults
- VNet peering to the hub
- Private DNS zone links from connectivity state
- user-assigned identity
- storage account
- Key Vault
- App Configuration
- Service Bus
- optional Azure SQL
- optional Azure Container Registry
- Linux Function App
- private endpoints for common PaaS services
- optional API Management
- optional Azure DevOps repository/project resources

Some services are behind toggles because APIM, Premium App Service plans, SQL, and ACR can be expensive for personal testing.

## Tagging Guidance

Based on the governance screenshots you shared, the blueprint standardizes around these core tags:

- `env`
- `application`
- `created_by`
- `bt_owner`
- `source_repo`
- `tf_workspace`
- `recovery`
- `cost_center`
- `data_classification`
- `compliance_boundary`

### About `creation_date` and `last_modified`

Do not manage those two tags naively in Terraform:

- `creation_date` should be written once and then treated as immutable.
- `last_modified` changes on every apply, which creates permanent drift if Terraform owns it directly.

Recommended patterns:

- write them outside Terraform with an automation function;
- or store them in a CMDB/inventory system instead of tags;
- or set them once and use `lifecycle.ignore_changes = [tags["creation_date"], tags["last_modified"]]` in resource-specific cases if you truly need them as tags.

## Remote State Pattern

Each active v2 stack uses an empty backend block:

```hcl
terraform {
  backend "azurerm" {}
}
```

Initialize with a per-stack backend config:

```bash
terraform init -backend-config=backend.hcl
```

Example `backend.hcl`:

```hcl
resource_group_name  = "rg-tfstate-dev"
storage_account_name = "demotest822e"
container_name       = "deploy-container"
key                  = "stacks/dev/platform-v2/connectivity.tfstate"
use_azuread_auth     = true
```

### Backend Best Practices

- Keep one backend storage account per environment or trust boundary.
- Keep one backend key per stack.
- Never share a single key across multiple stacks.
- Prefer Azure AD auth over shared keys and SAS tokens.
- Restrict write access to CI identities. Humans should generally be read-only.
- Keep the backend resource group and storage account in a platform-owned scope, not inside a workload stack.
- Enable blob versioning, blob soft delete, and container soft delete so state can be recovered.
- Enable infrastructure encryption and minimum TLS 1.2 on the backend account.
- Treat the backend account as critical infrastructure: lock it down with RBAC, diagnostics, and backup-friendly retention.

### Backend Layout Guidance

For personal testing, this repo uses:

- storage account `demotest822e`
- container `deploy-container`
- one blob key per v2 stack

For enterprise use, prefer:

- a dedicated backend storage account per environment or landing-zone trust boundary
- a separate backend subscription or shared platform subscription when required by policy
- separate keys for `bootstrap`, `governance`, `connectivity`, `management`, and each workload stack
- private endpoints plus self-hosted runners if the backend must not be publicly reachable

### Backend Security Rules

- Do not commit real `backend.hcl` files with environment-specific secrets or private endpoints.
- Commit `.terraform.lock.hcl` for every active stack.
- Do not commit `.terraform/`, `tfplan`, local state, or crash logs.
- Do not let workload identities write platform state.
- If using GitHub-hosted runners, keep backend public access enabled only when justified and IP restriction is not practical.
- If backend public access is disabled, run Terraform from a self-hosted runner in an allowed network path.

## State Locking, Blob Leasing, and Concurrency

Azure Blob backends use blob leases for state locking. One state key can have only one active writer at a time.

Operational rules:

- lease contention is expected when two runs hit the same key
- do not disable locking
- do not share a state key across unrelated stacks
- serialize applies with GitHub Actions `concurrency`
- use separate keys to reduce contention
- only run `terraform force-unlock` when you have confirmed the lock is stale

### Lease Handling Runbook

Use this order of operations when a stack appears locked:

1. Confirm whether another `plan` or `apply` is still running for the same stack.
2. Check the matching GitHub Actions run, local shell session, or CI agent before touching the lock.
3. Retry after the active run finishes; a waiting lease is normal behavior.
4. Use `terraform force-unlock <LOCK_ID>` only if the owning process is gone and you are certain no real apply is in flight.
5. After unlock, run `terraform plan` first. Do not go straight to apply.

### Concurrency Best Practices

- One concurrency group per stack path is the correct minimum control.
- Allow different stacks to plan in parallel when they use different backend keys.
- Do not run parallel applies against the same stack.
- Prefer reviewed-plan artifacts over recomputing a fresh plan during apply.
- Keep `cancel-in-progress: false` for applies so one run does not interrupt another mid-change.
- Be careful with scheduled drift jobs and manual applies against the same key. They should not overlap.

This repo’s plan/apply workflow uses:

- one concurrency group per stack path
- artifacted plans
- explicit manual dispatch for apply

## Drift Detection

`/.github/workflows/terraform-drift.yml` is OIDC-based and does the following:

- runs `terraform plan -detailed-exitcode`
- uploads the generated plan
- publishes the plan to the workflow summary
- opens or updates a GitHub issue when drift is detected
- closes the issue when drift clears

### Drift Operating Model

- schedule drift nightly or multiple times per day for critical stacks
- start with workload stacks, then add platform stacks
- keep `ARM_SKIP_PROVIDER_REGISTRATION=true` for drift jobs with read-only identities
- review drift before applying; do not auto-apply platform changes blindly
- treat repeated drift as a control failure, not just a pipeline nuisance

### Common Azure Drift Sources

- manual portal edits
- policy remediation tasks
- RBAC changes made outside Terraform
- diagnostic settings added by other tooling
- private endpoint or DNS changes made by networking teams
- eventual consistency around management groups, RBAC, and policy assignments

### Drift Triage Guidance

- If drift is expected and temporary, document it and close the gap quickly.
- If drift is caused by policy remediation, decide whether Terraform or policy should own the setting.
- If drift is caused by manual changes, import the resource or remove the manual process.
- If drift repeats on every run, fix the module contract instead of suppressing the symptom.

## Validation, Testing, and Scanning

`/.github/workflows/terraform-ci.yml` runs:

- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`
- Checkov with SARIF upload

### Minimum PR Gate

Every pull request should pass:

- formatting
- initialization without backend access
- validation
- static security scanning
- at least one stack plan before merge for changed stacks

### Recommended Test Layers

Use more than one type of test:

- `terraform validate` for syntax and provider schema
- `terraform test` for native module contract tests
- Checkov and TFLint for static analysis
- Terratest or Kitchen-Terraform for real Azure integration tests
- contract tests for cross-stack remote-state outputs
- smoke tests after apply for workload reachability and DNS resolution

### Native Terraform Test Guidance

As modules stabilize, add `tests/*.tftest.hcl` for:

- required variable validation
- output contracts
- expected plan-time assertions for secure defaults
- module behavior toggles such as optional SQL, APIM, or Azure DevOps resources

### Azure Integration Test Guidance

For integration tests in a real subscription:

- use ephemeral resource groups where possible
- avoid running destructive tests against shared platform stacks
- run connectivity and private-endpoint assertions after apply
- verify DNS resolution from inside an allowed network path, not just from the public internet
- test RBAC-managed services with managed identities, not only with deployer credentials

### Recommended Additions

- TFLint with Azure rules
- policy-as-code tests for custom policy definitions and initiatives
- `terraform providers lock` refresh in a controlled upgrade process
- a smoke test workflow that verifies private DNS, Function App reachability, and Key Vault resolution

## Plan and Apply Workflow

`/.github/workflows/terraform-plan-apply.yml` is:

- OIDC-based
- manually triggered
- parameterized by `stack_path`, `backend_config_path`, and `var_file`
- designed to produce a plan artifact before optional apply

### Production Workflow Controls

- use GitHub Environments with required reviewers for apply
- split nonprod and prod identities
- give platform pipelines higher scope than workload pipelines
- give workload pipelines only the scopes they actually deploy to
- avoid `Owner`; prefer `Contributor` plus `User Access Administrator` only where RBAC is managed
- protect the default branch and require CI before merge
- apply only the reviewed plan artifact, not a fresh recalculated plan
- keep production apply on a short allowlist of maintainers

### Azure Pipeline Identity Guidance

- Use OIDC federation from GitHub Actions to Entra ID.
- Keep one identity for platform stacks and separate identities for workload stacks where possible.
- Grant state access explicitly to the CI identity.
- If Terraform manages role assignments, the pipeline identity also needs the correct RBAC scope to do so.
- For drift-only jobs, use a read-oriented identity and keep provider registration disabled.

## Azure-Specific Best Practices

### Management Groups and Subscriptions

- Keep platform subscriptions separate from workload subscriptions.
- Associate subscriptions into management groups through code.
- Put governance at management group scope, not resource-group scope.

### Networking

- Use hub-spoke, not flat shared VNets.
- Centralize Private DNS zones.
- Link every spoke that hosts private-endpoint consumers.
- Keep a dedicated private-endpoints subnet.
- Add restrictive NSGs intentionally; do not rely on defaults.
- Document every service tag exception you allow.

### Key Vault

- Keep `public_network_access_enabled = false` unless there is a deliberate exception.
- Use RBAC mode by default.
- Do not auto-grant the deployer Key Vault Administrator everywhere.
- Plan for purge protection and name reuse constraints.

### Storage

- Set `allow_nested_items_to_be_public = false`.
- Set `min_tls_version = "TLS1_2"`.
- Enable versioning and retention.
- Be deliberate about `shared_access_key_enabled`; some services still require it.

### Functions and App Service

- Prefer Premium plans when private networking is required.
- Validate Function App storage dependencies when disabling public access.
- Keep `https_only = true`.
- Disable FTP/FTPS.
- Use Application Insights via workspace-based mode.

### APIM

- Treat APIM as optional in personal testing because of cost.
- For enterprise deployment, give APIM its own subnet and explicit NSG rules.
- If you move to internal mode, validate all required management ports and health probe requirements.

### SQL, Service Bus, App Configuration

- Disable public network access by default.
- Add private endpoints and DNS.
- Use managed identity and RBAC where possible.
- Avoid connection strings and local auth unless the service integration requires them.

## Azure DevOps Notes

The Azure DevOps module supports optional project and repository creation plus minimum-reviewer policy. It assumes you provide Azure DevOps authentication through provider configuration or environment variables.

Recommended environment variables:

- `AZDO_ORG_SERVICE_URL`
- `AZDO_PERSONAL_ACCESS_TOKEN`

Keep Azure DevOps resources optional so Terraform can still validate in environments that do not use Azure DevOps.

## Local Usage

Example flow for a stack:

```bash
cd terraform/stacks/dev/platform-v2/connectivity
cp backend.hcl.example backend.hcl
cp dev.tfvars.example dev.tfvars
terraform init -backend-config=backend.hcl
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Use the same flow for every stack.

## Cost Notes for Personal Testing

Reasonable low-cost path:

- deploy `platform-v2/bootstrap`
- deploy `platform-v2/governance`
- deploy `platform-v2/connectivity` without Azure Firewall
- deploy `platform-v2/management`
- deploy `workload-v2/finserv-api` with:
  - `enable_apim = false`
  - `enable_sql = false`
  - `enable_container_registry = false`
  - `enable_azuredevops = false`

Turn on APIM, SQL, ACR, and Premium egress controls only after the base pattern is working.

## Migration Notes

The old top-level Terraform monolith has been removed.

If you want to migrate the remaining legacy Terraform folders:

1. stop using `terraform/stacks/dev/platform`, `terraform/stacks/dev/workloads`, `terraform/stacks/prod/*`, and `terraform/global/*` in CI
2. move any missing state outputs into the new `terraform/stacks/dev/*-v2/*`
3. import surviving resources into the new v2 stacks where necessary
4. delete or archive the legacy stacks after state is fully migrated

## Validation Status

The active v2 stacks were validated locally. Before taking this to a client, rerun:

- `terraform fmt -recursive`
- `terraform init -backend=false`
- `terraform validate`
- `terraform test` for any stack or module with native tests
- `tflint`
- `checkov`
- reviewed `terraform plan` output for every changed stack
- scheduled drift detection for active stacks
- nonprod plans for every active v2 stack

Do that in your personal subscription first, then tighten any remaining provider or SKU details before recommending it to a client.
