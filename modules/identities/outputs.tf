output "entities" {
  value = { for k, e in vault_identity_entity.identity_entity : k => e.id }
}
output "groups" {
  value = { for k, g in vault_identity_group.group : k => g.id }
}
