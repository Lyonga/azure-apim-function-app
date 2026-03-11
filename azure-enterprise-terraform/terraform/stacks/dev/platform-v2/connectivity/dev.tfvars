environment         = "dev"
subscription_id     = "00000000-0000-0000-0000-000000000001"
application         = "connectivity"
created_by          = "terraform"
location            = "eastus2"
resource_group_name = "rg-dev-connectivity"
hub_vnet_name       = "vnet-dev-hub"

hub_address_space = [
  "10.0.0.0/16",
]

enable_firewall     = false
business_owner      = "network"
source_repo         = "azure-apim-function-app"
terraform_workspace = "platform-v2-connectivity-dev"
recovery_tier       = "terraform"
cost_center         = "shared-network"
creation_date_utc   = "2026-03-09T00:00:00Z"

additional_tags = {
  owner = "charles"
}
