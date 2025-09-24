output "entity_ids" {
  description = "Map of entity handle -> canonical entity ID"
  value       = { for k, e in vault_identity_entity.entity : k => e.id }
}

output "entity_alias_ids" {
  description = "Map of entity handle -> alias ID (only where object_id is set)"
  value       = { for k, a in vault_identity_entity_alias.entity_oid : k => a.id }
}

output "group_ids_internal" {
  description = "Map of internal group name -> group ID"
  value       = { for k, g in vault_identity_group.internal : k => g.id }
}

output "group_ids_external" {
  description = "Map of external group name -> group ID"
  value       = { for k, g in vault_identity_group.external : k => g.id }
}
