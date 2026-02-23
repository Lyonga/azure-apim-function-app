# Azure Enterprise Terraform Reference Project (Modules + Env Stacks)

This repository is a **production-grade learning scaffold** for Azure using Terraform:
- Reusable modules under `terraform/modules/*`
- Per-environment root stacks under `terraform/stacks/{dev,prod}/{platform,workloads}`
- Default tags applied consistently via `locals.tf`
- Optional patterns for:
  - Creating subscriptions (disabled by default)
  - Using existing subscriptions/resource groups
  - Remote state between stacks (workloads reads platform outputs)

> ✅ This is designed so you can "play around" and learn Azure patterns as an AWS-centric engineer,
> while still reflecting enterprise conventions (state boundaries, tagging, governance hooks).

## Quick start (recommended)
1. Install Terraform >= 1.6.
2. Authenticate to Azure:
   - **Local**: `az login` and `az account set --subscription <SUBSCRIPTION_ID>`
   - **CI/CD**: use OIDC federated credentials (recommended for enterprise)

3. Configure the backend:
   - Each stack has a `backend.tf` with an `azurerm` backend.
   - You must create a state storage account + container once (bootstrap) and then fill the backend values.

4. Deploy dev platform:
   ```bash
   cd terraform/stacks/dev/platform
   terraform init
   terraform plan -var-file=dev.tfvars
   terraform apply -var-file=dev.tfvars
   ```

5. Deploy dev workloads (reads platform remote state):
   ```bash
   cd terraform/stacks/dev/workloads
   terraform init
   terraform plan -var-file=dev.tfvars
   terraform apply -var-file=dev.tfvars
   ```

## Notes on "deployable"
- Modules are complete and valid Terraform.
- Some resources are **optional toggles** because enterprise orgs vary (e.g., subscription creation, ADO branch policies).
- You need appropriate Azure permissions to create AKS, Key Vault, etc.

## Structure
See `terraform/` for full layout.

