output "connections" {
  description = "DB connections keyed by db name"
  value = {
    for k, v in vault_database_secret_backend_connection.postgres_connection :
    k => {
      backend       = v.backend
      name          = v.name
      allowed_roles = v.allowed_roles
    }
  }
}

output "roles" {
  description = "DB roles keyed by db name"
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
