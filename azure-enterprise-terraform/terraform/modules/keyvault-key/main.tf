resource "azapi_resource" "this" {
  type      = "Microsoft.KeyVault/vaults/keys@2023-07-01"
  name      = var.name
  parent_id = var.key_vault_id

  body = {
    properties = {
      attributes = {
        enabled = true
      }
      keyOps  = var.key_ops
      keySize = var.key_size
      kty     = var.key_type
    }
  }

  response_export_values = ["*"]
}
