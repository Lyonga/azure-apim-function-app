environment          = "dev"
subscription_id      = "65ac2b14-e13a-40a0-bb50-93359232816e"
application          = "terraform-platform"
created_by           = "terraform"
location             = "eastus2"
resource_group_name  = "rg-tfstate-dev"
storage_account_name = "demotest822e"

containers = [
  "deploy-container",
]

business_owner      = "platform"
source_repo         = "azure-apim-function-app"
terraform_workspace = "platform-v2-bootstrap-dev"
recovery_tier       = "terraform"
cost_center         = "shared-platform"
creation_date_utc   = "2026-03-09T00:00:00Z"

additional_tags = {
  owner = "charles"
}
