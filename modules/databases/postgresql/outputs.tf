# Connections keyed by environment
output "connections" {
  description = "DB connections per environment"
  value = {
    for env, c in vault_database_secret_backend_connection.postgres_connection :
    env => {
      backend       = c.backend
      name          = c.name
      allowed_roles = c.allowed_roles
    }
  }
}

# Roles keyed by "<app>-<env>"
output "roles" {
  description = "Dynamic DB roles keyed by <app>-<env>"
  value = {
    for k, v in vault_database_secret_backend_role.postgres_role :
    k => {
      backend     = v.backend
      name        = v.name
      db_name     = v.db_name
      default_ttl = v.default_ttl
      max_ttl     = v.max_ttl
    }
  }
}

# Read policies per (app, env)
output "read_policies" {
  description = "Read policies keyed by <app>-<env>"
  value = {
    for k, p in vault_policy.read_db_app_env :
    k => p.name
  }
}

# Manager artifacts
output "manager_policy" {
  value = vault_policy.manager.name
}

output "manager_token_role" {
  value = vault_token_auth_backend_role.manager.role_name
}
