environment               = "dev"
location                  = "eastus"
project_name              = "demolab-dev"
ssh_public_key            = "ssh-rsa REPLACE_ME"
resource_group            = "rg-dev-demolabs-platform"
use_global_remote_state   = false
use_platform_remote_state = false
create_demo_vm            = false
create_demo_lb            = false
collection_name           = "someone-demo-apim"
service_plan_sku          = "Y1"
runtime                   = "python"
runtime_version           = "3.11"
storage_account_name      = "devdemolabsst0012"
app_settings = {
  FUNCTIONS_WORKER_RUNTIME = "python"
  WEBSITE_RUN_FROM_PACKAGE = "1"
}
tags = {
  owner       = "charles"
  cost_center = "demo-cc-1001"
}

vm_image = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
}
