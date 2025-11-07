output "team_private_policy_names" {
  description = "Per-team policies created."
  value       = { for k, p in vault_policy.team_private : k => p.name }
}

output "team_paths_seeded" {
  description = "Seeded secret paths."
  value       = {
    for k, s in vault_kv_secret_v2.team_placeholder :
    k => "${var.mount}/${s.name}"
  }
}
