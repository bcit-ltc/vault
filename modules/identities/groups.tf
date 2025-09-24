# External groups map to AAD groups via alias (no members here).
resource "vault_identity_group" "external" {
  for_each = local.external_groups

  name     = each.key
  type     = "external"
  policies = try(each.value.policies, [])
  metadata = try(each.value.metadata, {})
}

resource "vault_identity_group_alias" "external_oidc" {
  for_each       = local.external_groups
  name           = trimspace(each.value.alias_object_id)   # AAD Group Object Id (must match token claim)
  mount_accessor = var.oidc_auth_accessor
  canonical_id   = vault_identity_group.external[each.key].id
}

# Internal groups can include entity members and external group members.
resource "vault_identity_group" "internal" {
  for_each = local.internal_groups

  name     = each.key
  type     = "internal"
  policies = try(each.value.policies, [])
  metadata = try(each.value.metadata, {})

  member_entity_ids = [
    for h in sort(try(each.value.members.entities, [])) :
    vault_identity_entity.entity[h].id
  ]

  # Only allow external groups here to avoid self-referential conf.
  member_group_ids = [
    for g in sort(try(each.value.members.groups, [])) :
    vault_identity_group.external[g].id
  ]
}
