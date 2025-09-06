# Create groups first (no memberships here). Memberships are managed by dedicated resources below.
resource "vault_identity_group" "group" {
  for_each = var.groups

  name     = each.key
  type     = each.value.type
  metadata = each.value.metadata
  policies = each.value.policies

  # The provider will read back member_* fields that are managed by separate resources.
  # Ignore them here to prevent tug-of-war diffs.
  lifecycle {
    ignore_changes = [
      member_entity_ids,
      member_group_ids,
    ]
  }
}

# Derive desired memberships from input
locals {

  # Parent group -> list of entity names to include
  entity_memberships = {
    for parent, g in var.groups :
    parent => coalesce(try(g.members.entities, null), [])
  }

  # Parent group -> list of child group names to include
  group_memberships = {
    for parent, g in var.groups :
    parent => coalesce(try(g.members.groups, null), [])
  }
}

# Attach entity memberships (order-stable, filtered to declared entities)
resource "vault_identity_group_member_entity_ids" "member_entities" {
  for_each = {
    for parent, members in local.entity_memberships :
    parent => members
    if length(members) > 0
  }

  # Ensure groups/entities exist before we attach memberships
  depends_on = [vault_identity_group.group, vault_identity_entity.identity_entity]

  group_id = vault_identity_group.group[each.key].id

  # Stable, filtered list of IDs
  member_entity_ids = sort([
    for name in each.value :
    vault_identity_entity.identity_entity[name].id
    if contains(keys(vault_identity_entity.identity_entity), name)
  ])
}

# Attach group→group memberships (order-stable, filtered to declared groups)
resource "vault_identity_group_member_group_ids" "member_groups" {
  for_each = {
    for parent, members in local.group_memberships :
    parent => members
    if length(members) > 0
  }

  depends_on = [vault_identity_group.group, vault_identity_entity.identity_entity]

  group_id = vault_identity_group.group[each.key].id

  # Stable, filtered list of IDs
  member_group_ids = sort([
    for name in each.value :
    vault_identity_group.group[name].id
    if contains(keys(vault_identity_group.group), name)
  ])
}
