# Build unique sets of auth mount paths we’ll need accessors for
locals {
  group_mount_paths  = toset([for g in var.aliases.groups   : g.mount_path])
  entity_mount_paths = toset([for e in var.aliases.entities : e.mount_path])
  needed_mount_paths = setunion(local.group_mount_paths, local.entity_mount_paths)
}

# Look up auth mounts by path (expects bare mount names like "userpass", not "auth/userpass")
data "vault_auth_backend" "by_path" {
  for_each = local.needed_mount_paths
  path     = each.key
}

# Group aliases (aliasing Vault groups to external auth backends)
resource "vault_identity_group_alias" "group_alias" {
  for_each = {
    for g in var.aliases.groups : g.name => g
    if contains(keys(data.vault_auth_backend.by_path), g.mount_path)
  }

  # Alias string as it appears in the auth method (e.g., group name in GitHub/JWT)
  name           = each.value.alias_name
  mount_accessor = data.vault_auth_backend.by_path[each.value.mount_path].accessor

  # Canonical group ID by friendly name
  canonical_id   = vault_identity_group.group[each.value.name].id
}

# Entity aliases (aliasing Vault entities to external auth backends)
resource "vault_identity_entity_alias" "entity_alias" {
  for_each = {
    for e in var.aliases.entities : e.name => e
    if contains(keys(data.vault_auth_backend.by_path), e.mount_path)
  }

  name           = each.value.alias_name
  mount_accessor = data.vault_auth_backend.by_path[each.value.mount_path].accessor
  canonical_id   = vault_identity_entity.identity_entity[each.value.name].id
}
