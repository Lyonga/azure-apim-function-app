# Root management group id/name (check Azure Portal -> Management Groups)
root_management_group_id = "<TENANT_ROOT_MG_ID_OR_NAME>"

# Optional: existing subscriptions to place into MGs
connectivity_subscription_id     = "<SUB_ID_CONNECTIVITY>"
management_subscription_id       = "<SUB_ID_MANAGEMENT>"
prod_workload_subscription_id    = "<SUB_ID_PROD_WORKLOAD>"
nonprod_workload_subscription_id = "<SUB_ID_NONPROD_WORKLOAD>"

allowed_locations = ["eastus", "centralus"]
policy_mode       = "Audit"
