subscription_id     = "65ac2b14-e13a-40a0-bb50-93359232816e"
environment         = "dev"
application         = "governance"
created_by          = "terraform"
business_owner      = "security-engineering"
source_repo         = "azure-apim-function-app"
terraform_workspace = "platform-v2-governance-dev"
recovery_tier       = "terraform"
cost_center         = "shared-security"
creation_date_utc   = "2026-03-09T00:00:00Z"

root_management_group_id  = "/providers/Microsoft.Management/managementGroups/79dd759b-3fbe-4ab1-9439-ff87b14ba8f2"
organization_prefix       = "fin"
organization_display_name = "FinServ"

allowed_locations = [
  "eastus",
  "eastus2",
  "centralus",
]

subscriptions_by_group = {
  platform = ["65ac2b14-e13a-40a0-bb50-93359232816e"]
  nonprod  = ["ce792f64-9e63-483b-8136-a2538b764f3d"]
}

use_subscriptions_state             = true
subscriptions_state_rg              = "rg-tfstate-dev"
subscriptions_state_sa              = "demotest822e"
subscriptions_state_key             = "stacks/dev/platform-v2/subscriptions.tfstate"
subscriptions_state_subscription_id = "65ac2b14-e13a-40a0-bb50-93359232816e"

platform_deployer_principal_id         = ""
security_reader_principal_id           = ""
nonprod_workload_deployer_principal_id = ""
