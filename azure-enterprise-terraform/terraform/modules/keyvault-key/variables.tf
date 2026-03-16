variable "name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "key_type" {
  type    = string
  default = "RSA-HSM"
}

variable "key_size" {
  type    = number
  default = 2048
}

variable "key_ops" {
  type = list(string)
  default = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
