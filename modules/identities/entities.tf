resource "vault_identity_entity" "entity" {
  for_each = local.entities
  name     = each.value.name
  policies = each.value.policies  # [] if not specified in YAML
}

resource "vault_identity_entity_alias" "entity_oid" {
  for_each       = local.entities_with_alias
  name           = trimspace(each.value.object_id)   # Azure objectId
  mount_accessor = var.oidc_auth_accessor
  canonical_id   = vault_identity_entity.entity[each.key].id
}
