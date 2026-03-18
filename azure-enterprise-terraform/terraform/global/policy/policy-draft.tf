# -----------------------------------------------------------------------------
# Draft Financial-Sector Policy Backlog
# -----------------------------------------------------------------------------
#
# This file is intentionally non-active.
# Every block in this file is commented out so Terraform will ignore it until
# the team reviews and approves a specific policy.
#
# Why keep the draft here:
# - it keeps future policy ideas close to the active policy stack
# - it makes review easier because proposed controls are visible in one place
# - it avoids adding half-approved variables or outputs to the active stack
#
# Suggested workflow:
# 1. Review one draft policy at a time.
# 2. Validate the Azure resource aliases and built-in definition IDs.
# 3. Uncomment only the approved block(s).
# 4. Move approved code into `main.tf`, `variables.tf`, and `outputs.tf`.
# 5. Remove the approved block from this draft file.
#
# Important:
# - several of these controls are better implemented with Azure built-in
#   `deployIfNotExists` policies or service-specific built-ins rather than
#   custom policies
# - where the exact alias or built-in ID still needs confirmation, the draft is
#   marked `TODO`
# - keep all draft-only variables and outputs in this file until the control is
#   accepted
#
# -----------------------------------------------------------------------------
# Draft Variables
# -----------------------------------------------------------------------------
#
# variable "draft_financial_required_tags" {
#   type        = list(string)
#   description = "Extra regulated-workload tags to require if the team approves them."
#   default = [
#     "data_classification",
#     "service_owner",
#     "support_tier",
#     "criticality",
#     "rto",
#     "rpo",
#   ]
# }
#
# variable "draft_financial_allowed_vm_sizes" {
#   type        = list(string)
#   description = "Approved VM sizes for regulated environments."
#   default = [
#     "Standard_D2s_v5",
#     "Standard_D4s_v5",
#   ]
# }
#
# -----------------------------------------------------------------------------
# Draft Custom Policy Definitions
# -----------------------------------------------------------------------------
#
# 1. Require data-classification tag
#
# resource "azurerm_policy_definition" "draft_required_data_classification_tag" {
#   name                = "${var.organization_prefix}-draft-required-data-classification-tag"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "Indexed"
#   display_name        = "Require data classification tag"
#   description         = "Denies resources missing a data classification tag."
#
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field     = "type"
#           notEquals = "Microsoft.Resources/subscriptions/resourceGroups"
#         },
#         {
#           field  = "tags['data_classification']"
#           exists = "false"
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# 2. Require service-owner tag
#
# resource "azurerm_policy_definition" "draft_required_service_owner_tag" {
#   name                = "${var.organization_prefix}-draft-required-service-owner-tag"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "Indexed"
#   display_name        = "Require service owner tag"
#   description         = "Denies resources missing a service owner tag."
#
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field     = "type"
#           notEquals = "Microsoft.Resources/subscriptions/resourceGroups"
#         },
#         {
#           field  = "tags['service_owner']"
#           exists = "false"
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# 3. Deny storage shared-key access
#
# resource "azurerm_policy_definition" "draft_deny_storage_shared_key_access" {
#   name                = "${var.organization_prefix}-draft-deny-storage-shared-key"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "Indexed"
#   display_name        = "Deny shared-key access for storage accounts"
#   description         = "Requires storage accounts to disable shared-key authorization."
#
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field  = "type"
#           equals = "Microsoft.Storage/storageAccounts"
#         },
#         {
#           field     = "Microsoft.Storage/storageAccounts/allowSharedKeyAccess"
#           notEquals = false
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# 4. Require managed identity on App Service and Function App workloads
#
# resource "azurerm_policy_definition" "draft_require_managed_identity_for_webapps" {
#   name                = "${var.organization_prefix}-draft-require-managed-identity-webapps"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "All"
#   display_name        = "Require managed identity on App Service workloads"
#   description         = "Requires Microsoft.Web/sites resources to enable a managed identity."
#
#   # TODO: confirm the best alias path for identity enforcement in policy.
#   # This is a draft only and should not be uncommented without alias
#   # validation.
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field  = "type"
#           equals = "Microsoft.Web/sites"
#         },
#         {
#           field     = "identity.type"
#           equals    = "None"
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# 5. Deny local authentication on Service Bus
#
# resource "azurerm_policy_definition" "draft_deny_service_bus_local_auth" {
#   name                = "${var.organization_prefix}-draft-deny-service-bus-local-auth"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "All"
#   display_name        = "Deny local authentication on Service Bus"
#   description         = "Requires Service Bus namespaces to disable local auth."
#
#   # TODO: confirm the correct alias for disableLocalAuth before use.
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field  = "type"
#           equals = "Microsoft.ServiceBus/namespaces"
#         },
#         {
#           field     = "Microsoft.ServiceBus/namespaces/disableLocalAuth"
#           notEquals = true
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# 6. Require customer-managed keys for storage accounts
#
# resource "azurerm_policy_definition" "draft_require_storage_cmk" {
#   name                = "${var.organization_prefix}-draft-require-storage-cmk"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "Indexed"
#   display_name        = "Require customer-managed keys for storage accounts"
#   description         = "Requires storage accounts to use customer-managed keys."
#
#   # TODO: confirm aliases for keySource and encryption-key settings.
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field  = "type"
#           equals = "Microsoft.Storage/storageAccounts"
#         },
#         {
#           field     = "Microsoft.Storage/storageAccounts/encryption.keySource"
#           notEquals = "Microsoft.Keyvault"
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# 7. Restrict VM sizes to an approved list
#
# resource "azurerm_policy_definition" "draft_allowed_vm_sizes" {
#   name                = "${var.organization_prefix}-draft-allowed-vm-sizes"
#   management_group_id = local.management_group_ids["landing_zones"]
#   policy_type         = "Custom"
#   mode                = "All"
#   display_name        = "Allow approved VM sizes"
#   description         = "Restricts virtual machines to the approved size list."
#
#   parameters = jsonencode({
#     allowedVmSizes = {
#       type = "Array"
#       metadata = {
#         displayName = "Allowed VM sizes"
#         description = "Approved VM sizes for regulated workloads."
#       }
#     }
#   })
#
#   # TODO: validate exact aliases for VM size across all VM resource types.
#   policy_rule = jsonencode({
#     if = {
#       allOf = [
#         {
#           field  = "type"
#           equals = "Microsoft.Compute/virtualMachines"
#         },
#         {
#           field = "Microsoft.Compute/virtualMachines/hardwareProfile.vmSize"
#           notIn = "[parameters('allowedVmSizes')]"
#         }
#       ]
#     }
#     then = {
#       effect = "deny"
#     }
#   })
# }
#
# -----------------------------------------------------------------------------
# Draft Built-In Or DINE Policy Candidates
# -----------------------------------------------------------------------------
#
# These are strong candidates for a financial-services baseline, but they are
# better implemented with built-in policies or deployIfNotExists logic. Exact
# definition IDs should be confirmed before use.
#
# 8. Require diagnostic settings on:
#    - Key Vault
#    - Storage
#    - SQL
#    - Service Bus
#    - App Configuration
#    - App Service / Function App
#    - API Management
#    - ACR
#
# 9. Require Microsoft Defender plans for:
#    - Servers
#    - Storage
#    - SQL
#    - Key Vault
#    - Containers
#    - App Service
#    - ARM / control plane
#
# 10. Require private endpoints for sensitive data services
#
# 11. Require backup coverage for critical workloads
#
# 12. Require SQL vulnerability assessment and auditing
#
# 13. Require minimum TLS 1.2 or higher on all supported services
#
# 14. Deny public network access on any additional PaaS services introduced
#     later, such as:
#     - ACR
#     - Redis
#     - Event Hubs
#     - Cosmos DB
#     - AI services
#
# 15. Audit or deny broad RBAC assignments such as:
#     - Owner at subscription scope
#     - excessive Contributor assignments at high scope
#
# -----------------------------------------------------------------------------
# Draft Initiative Example
# -----------------------------------------------------------------------------
#
# resource "azurerm_policy_set_definition" "draft_financial_services_baseline" {
#   name                = "${var.organization_prefix}-draft-financial-services-baseline"
#   display_name        = "Draft Financial Services Baseline"
#   policy_type         = "Custom"
#   management_group_id = local.management_group_ids["landing_zones"]
#
#   # Uncomment approved draft policies here after review.
#   # policy_definition_reference {
#   #   policy_definition_id = azurerm_policy_definition.draft_required_data_classification_tag.id
#   #   reference_id         = "requiredDataClassificationTag"
#   # }
#
#   # policy_definition_reference {
#   #   policy_definition_id = azurerm_policy_definition.draft_required_service_owner_tag.id
#   #   reference_id         = "requiredServiceOwnerTag"
#   # }
#
#   # policy_definition_reference {
#   #   policy_definition_id = azurerm_policy_definition.draft_deny_storage_shared_key_access.id
#   #   reference_id         = "denyStorageSharedKeyAccess"
#   # }
# }
#
# resource "azurerm_management_group_policy_assignment" "draft_financial_services_baseline_nonprod" {
#   name                 = "${var.organization_prefix}-draft-financial-services-baseline-nonprod"
#   display_name         = "Draft Financial Services Baseline - Nonprod"
#   management_group_id  = local.management_group_ids["nonprod"]
#   policy_definition_id = azurerm_policy_set_definition.draft_financial_services_baseline.id
# }
#
# -----------------------------------------------------------------------------
# Draft Outputs
# -----------------------------------------------------------------------------
#
# output "draft_financial_policy_candidates" {
#   description = "Human-readable list of draft financial-sector policy candidates."
#   value = [
#     "Require data classification tag",
#     "Require service owner tag",
#     "Deny storage shared-key access",
#     "Require managed identity on App Service workloads",
#     "Deny local authentication on Service Bus",
#     "Require customer-managed keys for storage accounts",
#     "Restrict VM sizes to an approved list",
#     "Require diagnostic settings on critical PaaS services",
#     "Require Microsoft Defender plans for critical services",
#     "Require private endpoints for sensitive data services",
#     "Require backup coverage for critical workloads",
#     "Require SQL vulnerability assessment and auditing",
#     "Require minimum TLS 1.2 or higher on supported services",
#     "Deny public access on additional future PaaS services",
#     "Audit or deny broad RBAC assignments at high scope",
#   ]
# }
#
# -----------------------------------------------------------------------------
# Summary List For Review
# -----------------------------------------------------------------------------
#
# Proposed financial-sector policy additions currently captured in this draft:
#
# - Require `data_classification` tag
# - Require `service_owner` tag
# - Deny storage shared-key access
# - Require managed identity on App Service and Function App workloads
# - Deny local authentication on Service Bus
# - Require customer-managed keys for storage accounts
# - Restrict VM sizes to an approved list
# - Require diagnostic settings on critical PaaS services
# - Require Microsoft Defender plans on critical services
# - Require private endpoints for sensitive data services
# - Require backup coverage for critical workloads
# - Require SQL vulnerability assessment and auditing
# - Require minimum TLS 1.2 or higher on supported services
# - Deny public network access on additional future PaaS services
# - Audit or deny overly broad RBAC assignments at high scope
