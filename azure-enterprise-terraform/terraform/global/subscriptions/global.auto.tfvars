subscription_id = "65ac2b14-e13a-40a0-bb50-93359232816e"

target_subscriptions = {
  platform = {
    management_group_key      = "platform"
    existing_subscription_id  = "65ac2b14-e13a-40a0-bb50-93359232816e"
    subscription_display_name = "FinServ Platform"
  }

  nonprod_workload = {
    management_group_key      = "nonprod"
    existing_subscription_id  = "ce792f64-9e63-483b-8136-a2538b764f3d"
    subscription_display_name = "FinServ Nonprod Workloads"
  }
}
