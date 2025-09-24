# Mounts
locals {
  transit_mounts = [
    { name = "transit", description = "Encryption as a service" },
    { name = "sops",    description = "Mozilla SOPS (Secrets OPerationS)" },
  ]
  mounts_by_name = { for m in local.transit_mounts : m.name => m }
}

resource "vault_mount" "transit_mounts" {
  for_each    = local.mounts_by_name
  path        = each.value.name
  type        = "transit"
  description = each.value.description
  # lifecycle { prevent_destroy = true }
}

# Keys used by transit engine
locals {
  transit_keys = {
    "primary-signing-key" = { backend = "transit", type = "ecdsa-p256" }
    "gitops-key"        = { backend = "sops",    type = "rsa-2048" }
  }
}

resource "vault_transit_secret_backend_key" "keys" {
  for_each = local.transit_keys

  backend = vault_mount.transit_mounts[each.value.backend].path
  name    = each.key
  type    = each.value.type

  exportable             = false
  allow_plaintext_backup = false
  deletion_allowed       = true
  # lifecycle { prevent_destroy = true }
}
