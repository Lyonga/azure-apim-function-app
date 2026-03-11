subscription_id = "ce792f64-9e63-483b-8136-a2538b764f3d"

# Existing subscription path:
# - use existing_subscription_id when the subscription already exists
# - this is the safest default for normal dev testing
# - these entries create catalog outputs only; they do not vend subscriptions
target_subscriptions = {
  platform = {
    management_group_key      = "platform"
    existing_subscription_id  = "ce792f64-9e63-483b-8136-a2538b764f3d"
    subscription_display_name = "FinServ Platform"
  }
  connectivity = {
    management_group_key      = "connectivity"
    existing_subscription_id  = "00000000-0000-0000-0000-000000000001"
    subscription_display_name = "FinServ Connectivity"
  }
  management = {
    management_group_key      = "management"
    existing_subscription_id  = "00000000-0000-0000-0000-000000000002"
    subscription_display_name = "FinServ Management"
  }
  identity = {
    management_group_key      = "identity"
    existing_subscription_id  = "00000000-0000-0000-0000-000000000005"
    subscription_display_name = "FinServ Identity"
  }
  nonprod_workload = {
    management_group_key      = "nonprod"
    existing_subscription_id  = "ce792f64-9e63-483b-8136-a2538b764f3d"
    subscription_display_name = "FinServ Nonprod Workloads"
  }

  # Vended subscription path:
  # - switch enable_alias_creation to true
  # - set a real billing_scope_id
  # - ensure the deploying identity has subscription alias permission
  sandbox_vended = {
    management_group_key      = "sandbox"
    subscription_display_name = "FinServ Sandbox Vended"
    enable_alias_creation     = false
    billing_scope_id          = null
    workload                  = "DevTest"
  }
}
