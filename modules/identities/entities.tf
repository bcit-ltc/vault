resource "vault_identity_entity" "identity_entity" {
  for_each = var.entities
  name     = each.key
  metadata = each.value.metadata
  policies = each.value.policies
}
