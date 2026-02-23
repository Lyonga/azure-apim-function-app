# Subscription creation is highly enterprise-specific (EA vs MCA, permissions, etc).
# This module is OFF by default so the overall project remains deployable.

resource "azapi_resource" "subscription_alias" {
  count     = var.enable ? 1 : 0
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = replace(lower(var.subscription_display_name), " ", "-")
  parent_id = "/"

  body = jsonencode({
    properties = {
      displayName = var.subscription_display_name
      workload    = var.workload
      billingScope = var.billing_scope_id
    }
  })
}
