locals {
  ttl_1h  = 3600       # 1 hour
  ttl_24h = 86400      # 24 hours
  backend_path = var.manage_mount ? vault_mount.postgres_db[0].path : var.db_mount_path
  app_db_names = { for app in var.postgresql_databases : app => replace(app, "-", "_") }
}

resource "vault_mount" "postgres_db" {
  count = var.manage_mount ? 1 : 0
  path  = var.db_mount_path
  type  = "database"
  lifecycle {
    prevent_destroy = true   # nice safety so we don’t nuke the engine by accident
  }
}

resource "vault_database_secret_backend_connection" "postgres_connection" {
  for_each      = toset(var.postgresql_databases)
  backend       = local.backend_path
  name          = "pg-core-${each.value}"
  allowed_roles = ["${each.value}"]

  postgresql {
    # use the admin DB for verification
    connection_url = "postgresql://{{username}}:{{password}}@${var.pg_host}:${var.pg_port}/postgres?sslmode=require"
    username       = var.admin_username
    password       = var.admin_password
    password_authentication = "scram-sha-256"
    max_open_connections    = 8
    max_connection_lifetime = 300
  }
}

resource "vault_database_secret_backend_role" "postgres_role" {
  for_each     = toset(var.postgresql_databases)
  backend      = local.backend_path
  name         = "${each.value}"
  db_name      = vault_database_secret_backend_connection.postgres_connection[each.value].name
  default_ttl  = local.ttl_1h
  max_ttl      = local.ttl_24h

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT obot_app TO \"{{name}}\";",
    "ALTER ROLE \"{{name}}\" IN DATABASE obot SET search_path = obot, public;"
  ]

  # Nice cleanup when creds expire/revoke
  revocation_statements = [
    "REVOKE obot_app FROM \"{{name}}\";",
    "DROP ROLE IF EXISTS \"{{name}}\";"
  ]
}
