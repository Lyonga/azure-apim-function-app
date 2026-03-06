

locals {
  env          = var.environment
  project      = var.project_name
  collection   = var.collection_name
  name_prefix  = lower(replace(local.collection, " ", ""))
  tags_common  = merge(var.tags, {
    environment = local.env
    project     = local.project
    managed_by  = "terraform"
  })
  # Names
  rg_name      = "rg-${local.name_prefix}"
  law_name     = "law-${local.env}-${local.project}"
  appi_name    = "aai-${local.name_prefix}"
  sa_name      = "st${replace(local.name_prefix, "-", "")}"
}