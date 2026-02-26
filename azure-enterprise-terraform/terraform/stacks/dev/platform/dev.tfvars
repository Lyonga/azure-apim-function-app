environment          = "dev"
location             = "eastus"
create_resource_group = true
resource_group_name  = "${var.environment}-rg-demo-labs-platform"

project_name = "azure-enterprise-lab"
owner        = "charles"
cost_center  = "cc-1001"

# Make these unique per your Azure tenant:
storage_account_name = "${var.environment}-demo-labs-storage001-acc"
acr_name             = "${var.environment}-acr-demo-lab-001"
keyvault_name        = "${var.environment}-kv-demo-lab-001"
policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
