# External groups (IdP-mapped)
resource "vault_identity_group" "external" {
  for_each = local.external_groups

  name     = each.key
  type     = "external"
  metadata = try(each.value.metadata, {})

  # Do NOT manage policy attachments here.
  lifecycle { ignore_changes = [policies] }
}

resource "vault_identity_group_alias" "external_oidc" {
  for_each       = local.external_groups
  name           = trimspace(each.value.alias_object_id)   # AAD Group Object Id (must match token claim)
  mount_accessor = var.oidc_auth_accessor
  canonical_id   = vault_identity_group.external[each.key].id
}

# Attach policies to EXTERNAL groups (merge YAML + extras)
resource "vault_identity_group_policies" "external" {
  for_each = local.external_groups

  group_id = vault_identity_group.external[each.key].id
  policies = sort(distinct(concat(
    try(each.value.policies, []),               # from identities.yaml
    try(var.extra_group_policies[each.key], []) # injected by callers (e.g., team-private-*)
  )))
}

# Internal groups (managed here)
resource "vault_identity_group" "internal" {
  for_each = local.internal_groups

  name     = each.key
  type     = "internal"
  metadata = try(each.value.metadata, {})

  member_entity_ids = [
    for h in sort(try(each.value.members.entities, [])) :
    vault_identity_entity.entity[h].id
  ]

  # Only allow external groups here to avoid self-referential configs
  member_group_ids = [
    for g in sort(try(each.value.members.groups, [])) :
    vault_identity_group.external[g].id
  ]

  # Do NOT manage policy attachments here.
  lifecycle { ignore_changes = [policies] }
}

# Attach policies to INTERNAL groups (merge YAML + extras)
resource "vault_identity_group_policies" "internal" {
  for_each = local.internal_groups

  group_id = vault_identity_group.internal[each.key].id
  policies = sort(distinct(concat(
    try(each.value.policies, []),               # from identities.yaml
    try(var.extra_group_policies[each.key], []) # injected by callers (e.g., team-private-*)
  )))
}
