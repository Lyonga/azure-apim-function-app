environment                  = "dev"
subscription_id              = "ce792f64-9e63-483b-8136-a2538b764f3d"
location                     = "eastus2"
application                  = "loans-api"
created_by                   = "terraform"
business_owner               = "plant_enablement"
cost_center                  = "loans"
source_repo                  = "azure-apim-function-app"
terraform_workspace          = "workload-v2-finserv-api-dev"
recovery_tier                = "rubrik"
creation_date_utc            = "2026-03-09T00:00:00Z"
workload_resource_group_name = "rg-dev-loans-api"
spoke_vnet_name              = "vnet-dev-loans-api"

spoke_address_space = [
  "10.20.0.0/16",
]

storage_account_name   = "stdevloansapi001"
key_vault_name         = "kv-dev-loans-api"
function_app_name      = "fa-dev-loans-api"
service_bus_name       = "sb-dev-loans-api"
app_configuration_name = "appcs-dev-loans-api"

connectivity_state_rg  = "rg-tfstate-dev"
connectivity_state_sa  = "demotest822e"
connectivity_state_key = "stacks/dev/platform-v2/connectivity.tfstate"

management_state_rg  = "rg-tfstate-dev"
management_state_sa  = "demotest822e"
management_state_key = "stacks/dev/platform-v2/management.tfstate"

platform_state_subscription_id      = "65ac2b14-e13a-40a0-bb50-93359232816e"
identity_state_rg                   = "rg-tfstate-dev"
identity_state_sa                   = "demotest822e"
identity_state_key                  = "stacks/dev/platform-v2/identity.tfstate"
subscriptions_state_subscription_id = "65ac2b14-e13a-40a0-bb50-93359232816e"
connectivity_state_subscription_id  = "65ac2b14-e13a-40a0-bb50-93359232816e"
management_state_subscription_id    = "65ac2b14-e13a-40a0-bb50-93359232816e"
identity_state_subscription_id      = "65ac2b14-e13a-40a0-bb50-93359232816e"

enable_apim               = false
enable_sql                = false
enable_container_registry = false
enable_azuredevops        = false

additional_tags = {
  owner = "charles"
}
