# KV secrets engines (loop-driven)

# Edit this list to add/remove mounts. Each item is name/description/version.
locals {
  mounts = [
    { name = "apps",               description = "Secrets used within apps", version = 2 },
    { name = "private-team",       description = "Team secrets - only accessible by team members", version = 2 },
    { name = "external",           description = "Secrets for services or stand-alone projects outside the LTC", version = 2 },
    { name = "ltc-infrastructure", description = "Inventory and configuration secrets", version = 2 },
  ]
}

# Index by mount name
locals {
  mounts_by_name = { for m in local.mounts : m.name => m }
}

resource "vault_mount" "kv_mount" {
  for_each    = local.mounts_by_name

  path        = each.value.name
  type        = "kv"
  description = each.value.description
  options     = { version = tostring(each.value.version) }

  # Avoid nuking a mount (and all its data) via Terraform
  lifecycle { prevent_destroy = true }
}
