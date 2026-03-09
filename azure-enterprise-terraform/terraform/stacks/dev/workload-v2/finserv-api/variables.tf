variable "environment" {
  type        = string
  description = "Environment tag."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "application" {
  type        = string
  description = "Application code."
}

variable "created_by" {
  type        = string
  description = "Provisioning source tag."
  default     = "terraform"
}

variable "workload_resource_group_name" {
  type        = string
  description = "Workload resource group name."
}

variable "spoke_vnet_name" {
  type        = string
  description = "Workload spoke VNet name."
}

variable "spoke_address_space" {
  type        = list(string)
  description = "Workload spoke CIDR ranges."
}

variable "app_subnet_cidr" {
  type        = string
  description = "Application subnet CIDR."
  default     = "10.20.1.0/24"
}

variable "integration_subnet_cidr" {
  type        = string
  description = "Integration subnet CIDR."
  default     = "10.20.2.0/24"
}

variable "data_subnet_cidr" {
  type        = string
  description = "Data subnet CIDR."
  default     = "10.20.3.0/24"
}

variable "private_endpoints_subnet_cidr" {
  type        = string
  description = "Private endpoints subnet CIDR."
  default     = "10.20.10.0/24"
}

variable "apim_subnet_cidr" {
  type        = string
  description = "Optional APIM subnet CIDR."
  default     = "10.20.20.0/24"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name."
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name."
}

variable "function_app_name" {
  type        = string
  description = "Function App name."
}

variable "enable_apim" {
  type        = bool
  description = "Enable API Management."
  default     = false
}

variable "api_management_name" {
  type        = string
  description = "API Management name."
  default     = null
}

variable "publisher_name" {
  type        = string
  description = "APIM publisher name."
  default     = null
}

variable "publisher_email" {
  type        = string
  description = "APIM publisher email."
  default     = null
}

variable "api_name" {
  type        = string
  description = "API name in APIM."
  default     = "finserv-api"
}

variable "api_display_name" {
  type        = string
  description = "API display name."
  default     = "FinServ API"
}

variable "api_path" {
  type        = string
  description = "API path."
  default     = "finserv"
}

variable "api_spec_path" {
  type        = string
  description = "Optional absolute or relative path to the OpenAPI file."
  default     = null
}

variable "enable_service_bus" {
  type        = bool
  description = "Enable Service Bus."
  default     = true
}

variable "service_bus_name" {
  type        = string
  description = "Service Bus namespace name."
  default     = null
}

variable "enable_app_configuration" {
  type        = bool
  description = "Enable App Configuration."
  default     = true
}

variable "app_configuration_name" {
  type        = string
  description = "App Configuration name."
  default     = null
}

variable "enable_sql" {
  type        = bool
  description = "Enable Azure SQL."
  default     = false
}

variable "sql_server_name" {
  type        = string
  description = "Azure SQL server name."
  default     = null
}

variable "sql_databases" {
  type        = map(any)
  description = "Databases to create."
  default     = {}
}

variable "sql_aad_admin_login" {
  type        = string
  description = "Azure AD admin login for SQL."
  default     = null
}

variable "sql_aad_admin_object_id" {
  type        = string
  description = "Azure AD admin object id for SQL."
  default     = null
}

variable "enable_container_registry" {
  type        = bool
  description = "Enable ACR."
  default     = false
}

variable "container_registry_name" {
  type        = string
  description = "Azure Container Registry name."
  default     = null
}

variable "container_registry_replica_locations" {
  type        = list(string)
  description = "Secondary Azure regions for ACR geo-replication."
  default     = ["centralus"]
}

variable "service_plan_sku" {
  type        = string
  description = "Function App service plan SKU."
  default     = "EP1"
}

variable "function_public_network_access_enabled" {
  type        = bool
  description = "Allow public access to the Function App."
  default     = false
}

variable "enable_function_private_endpoint" {
  type        = bool
  description = "Create a private endpoint for the Function App."
  default     = true
}

variable "function_app_settings" {
  type        = map(string)
  description = "Additional Function App settings."
  default     = {}
}

variable "enable_azuredevops" {
  type        = bool
  description = "Create Azure DevOps project and repository resources."
  default     = false
}

variable "create_azuredevops_project" {
  type        = bool
  description = "Create a new Azure DevOps project."
  default     = false
}

variable "azuredevops_project_name" {
  type        = string
  description = "Azure DevOps project name."
  default     = null
}

variable "azuredevops_repository_name" {
  type        = string
  description = "Azure DevOps repository name."
  default     = null
}

variable "azuredevops_default_branch" {
  type        = string
  description = "Azure DevOps default branch reference."
  default     = "refs/heads/main"
}

variable "business_owner" {
  type        = string
  description = "Business owner tag."
}

variable "source_repo" {
  type        = string
  description = "Source repository tag."
  default     = "azure-apim-function-app"
}

variable "terraform_workspace" {
  type        = string
  description = "Terraform workspace or stack name."
  default     = "workload-finserv-api"
}

variable "recovery_tier" {
  type        = string
  description = "Recovery method tag."
  default     = "rubrik"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag."
}

variable "compliance_boundary" {
  type        = string
  description = "Compliance boundary tag."
  default     = "finserv"
}

variable "creation_date_utc" {
  type        = string
  description = "Optional immutable creation timestamp tag."
  default     = null
}

variable "last_modified_utc" {
  type        = string
  description = "Optional last modified timestamp tag."
  default     = null
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags."
  default     = {}
}

variable "connectivity_state_rg" {
  type        = string
  description = "Connectivity state resource group."
}

variable "connectivity_state_sa" {
  type        = string
  description = "Connectivity state storage account."
}

variable "connectivity_state_container" {
  type        = string
  description = "Connectivity state container."
  default     = "deploy-container"
}

variable "connectivity_state_key" {
  type        = string
  description = "Connectivity state key."
}

variable "management_state_rg" {
  type        = string
  description = "Management state resource group."
}

variable "management_state_sa" {
  type        = string
  description = "Management state storage account."
}

variable "management_state_container" {
  type        = string
  description = "Management state container."
  default     = "deploy-container"
}

variable "management_state_key" {
  type        = string
  description = "Management state key."
}
