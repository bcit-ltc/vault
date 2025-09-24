output "role_ids" {
  description = "Map of approle role_name -> RoleID"
  value       = { for k, v in data.vault_approle_auth_backend_role_id.role_ids : k => v.role_id }
}

output "backend_path" {
  description = "Path where the AppRole backend is mounted"
  value       = vault_auth_backend.approle.path
}
