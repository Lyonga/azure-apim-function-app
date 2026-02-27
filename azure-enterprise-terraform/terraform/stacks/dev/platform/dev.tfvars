environment          = "dev"
location             = "eastus"
create_resource_group = true
resource_group_name  = "demo-labs-platform"
project     = "demo-labs"
name_suffix = "0012"

project_name = "azure-enterprise-lab"
owner        = "charles"
cost_center  = "demo-cc-1001"

# Make these unique per your Azure tenant:
storage_account_name = "demo-labs-storage001-acc"
acr_name             = "demo-labs"
keyvault_name        = "kv-demo-labs"
policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
