environment          = "dev"
location             = "eastus"
create_resource_group = true
resource_group_name  = "rg-dev-platform"

project_name = "azure-enterprise-lab"
owner        = "charles"
cost_center  = "cc-1001"

# Make these unique per your Azure tenant:
storage_account_name = "demotest822e"
acr_name             = "acrdevlab001"
keyvault_name        = "kv-dev-lab-001"
