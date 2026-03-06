environment  = "dev"
location     = "eastus"
project_name = "azure-enterprise-lab-dev"

ssh_public_key = "ssh-rsa REPLACE_ME"

location        = "eastus"
resource_group  = "rg-dev-demolabs-platform"
environment     = "dev"
project_name    = "demo"
collection_name = "someone-demo-apim"

service_plan_sku = "Y1"
runtime          = "python"
runtime_version  = "3.11"

storage_account_name = "devdemolabsst0012"
storage_account_key  = "REDACTED-PRIMARY-KEY"

app_settings = {
  FUNCTIONS_WORKER_RUNTIME = "python"
  WEBSITE_RUN_FROM_PACKAGE = "1"
}

tags = {
  owner       = "charles"
  cost_center = "demo-cc-1001"
}