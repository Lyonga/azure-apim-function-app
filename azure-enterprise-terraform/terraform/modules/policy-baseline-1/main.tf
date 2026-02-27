# Built-in: Allowed locations
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

resource "azurerm_policy_assignment" "allowed_locations" {
  name                 = "alz-allowed-locations"
  scope                = var.scope_id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# Built-in: Require a tag (we assign once per required tag for reliability)
data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resources"
}

resource "azurerm_policy_assignment" "require_tags" {
  for_each             = var.required_tags
  name                 = "alz-require-tag-${each.key}"
  scope                = var.scope_id
  policy_definition_id = data.azurerm_policy_definition.require_tag.id

  parameters = jsonencode({
    tagName = { value = each.key }
  })
}

# Built-in: Public IP addresses should not be created
data "azurerm_policy_definition" "deny_public_ip" {
  display_name = "Public IP addresses should not be created"
}

resource "azurerm_policy_assignment" "deny_public_ip" {
  name                 = "alz-public-ip-${lower(var.policy_mode)}"
  scope                = var.scope_id
  policy_definition_id = data.azurerm_policy_definition.deny_public_ip.id

  # For built-ins, effect changes are not always parameterized.
  # Many orgs implement custom policies for explicit Audit/Deny. We keep baseline simple:
  # - Use Audit first by not assigning, then assign when ready (recommended), OR
  # - Replace with a custom definition in your org.
  # Here we always assign; Azure's built-in is deny-like.
}
