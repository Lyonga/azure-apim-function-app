prefix      = "contoso"
environment = "dev"
location    = "eastus"
location_short = "eus"
service_name = "sample"

tags = {
  owner      = "app-team"
  costCenter = "12345"
}

# Fill these from stacks/platform-connectivity outputs
hub_vnet_id   = "<HUB_VNET_ID>"
hub_vnet_name = "<HUB_VNET_NAME>"
hub_rg_name   = "<HUB_RG_NAME>"

# Fill this from stacks/platform-management output
log_analytics_workspace_id = "<LOG_ANALYTICS_WORKSPACE_ID>"

spoke_address_space = ["10.10.0.0/16"]
