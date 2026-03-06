
locals {
  tags_common = merge(var.tags, { managed_by = "terraform" })
}
