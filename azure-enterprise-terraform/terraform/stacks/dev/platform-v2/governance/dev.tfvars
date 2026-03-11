subscription_id     = "00000000-0000-0000-0000-000000000004"
environment         = "dev"
application         = "governance"
created_by          = "terraform"
business_owner      = "security-engineering"
source_repo         = "azure-apim-function-app"
terraform_workspace = "platform-v2-governance-dev"
recovery_tier       = "terraform"
cost_center         = "shared-security"
creation_date_utc   = "2026-03-09T00:00:00Z"

root_management_group_id  = "/providers/Microsoft.Management/managementGroups/00000000-0000-0000-0000-000000000000"
organization_prefix       = "fin"
organization_display_name = "FinServ"

allowed_locations = [
  "eastus2",
  "centralus",
]

subscriptions_by_group = {
  platform     = ["00000000-0000-0000-0000-000000000004"]
  connectivity = ["00000000-0000-0000-0000-000000000001"]
  management   = ["00000000-0000-0000-0000-000000000002"]
  identity     = ["00000000-0000-0000-0000-000000000005"]
  nonprod      = ["00000000-0000-0000-0000-000000000003"]
}

use_subscriptions_state             = true
subscriptions_state_rg              = "rg-tfstate-dev"
subscriptions_state_sa              = "demotest822e"
subscriptions_state_key             = "stacks/dev/platform-v2/subscriptions.tfstate"
subscriptions_state_subscription_id = "00000000-0000-0000-0000-000000000004"

platform_deployer_principal_id         = "00000000-0000-0000-0000-000000000010"
security_reader_principal_id           = "00000000-0000-0000-0000-000000000011"
nonprod_workload_deployer_principal_id = "00000000-0000-0000-0000-000000000012"
