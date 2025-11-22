locals {
  # Canonicalized env slugs
  envs = distinct([for e in var.envs : lower(trimspace(e))])

  # Mount path per env: <prefix>-<env>, e.g. "postgresql-stable"
  mounts = { for e in local.envs : e => "${var.db_mount_prefix}-${e}" }

  # Strict per-env connection params
  env_conn = {
    for e in local.envs : e => {
      host = var.pg_connections[e].host
      port = var.pg_connections[e].port
    }
  }

  # App database identifiers safe for PG (for schema/group names)
  # e.g. "qcon-api" -> "qcon_api"
  app_db_names = { for app in var.postgresql_databases : app => replace(app, "-", "_") }

  # (app,env) pairs → role name is "<app>-<env>"
  app_env_pairs = {
    for pair in flatten([
      for app in var.postgresql_databases : [
        for e in local.envs : {
          key    = "${app}-${e}"
          app    = app
          app_pg = replace(app, "-", "_")  # DB/schema name
          env    = e
          role   = "${app}-${e}"           # Vault DB role name
        }
      ]
    ]) : pair.key => pair
  }
}

# One mount per environment (e.g. "postgresql-stable", "postgresql-latest")
resource "vault_mount" "postgres_db" {
  for_each = local.mounts
  path     = each.value
  type     = "database"
}

# One connection per environment
resource "vault_database_secret_backend_connection" "postgres_connection" {
  for_each      = local.env_conn
  backend       = vault_mount.postgres_db[each.key].path
  name          = "${var.connection_name}-${each.key}"
  plugin_name   = var.plugin_name
  allowed_roles = ["*"]

  postgresql {
    connection_url          = "postgresql://{{username}}:{{password}}@${each.value.host}:${each.value.port}/${var.admin_database}?sslmode=require"

    # Hard-code the admin username
    username                = "postgres"

    # Per-environment admin password, keyed by env (e.g. "stable", "latest")
    password                = var.admin_passwords[each.key]

    password_authentication = "scram-sha-256"
    max_open_connections    = 8
    max_connection_lifetime = 300
  }
}

# One dynamic role per (app, env)
resource "vault_database_secret_backend_role" "postgres_role" {
  for_each    = local.app_env_pairs

  backend     = vault_mount.postgres_db[each.value.env].path
  name        = each.value.role
  db_name     = vault_database_secret_backend_connection.postgres_connection[each.value.env].name
  default_ttl = var.default_ttl_seconds
  max_ttl     = var.max_ttl_seconds

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT ${each.value.app_pg}${var.app_role_suffix} TO \"{{name}}\";",
    "ALTER ROLE \"{{name}}\" IN DATABASE ${each.value.app_pg} SET search_path = ${each.value.app_pg}, public;"
  ]

  renew_statements = [
    "ALTER ROLE \"{{name}}\" WITH PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "ALTER ROLE \"{{name}}\" IN DATABASE ${each.value.app_pg} SET search_path = ${each.value.app_pg}, public;"
  ]

  revocation_statements = [
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = '{{name}}';",
    "REVOKE ${each.value.app_pg}${var.app_role_suffix} FROM \"{{name}}\";",
    "DROP ROLE IF EXISTS \"{{name}}\";"
  ]
}

# Manager policy+token role (always created)
resource "vault_policy" "manager" {
  name   = "manage-${var.db_mount_prefix}"
  policy = join("\n", concat(
    [
      "path \"sys/mounts\" { capabilities = [\"read\"] }",
      "path \"auth/token/lookup-self\" { capabilities = [\"read\"] }",
      "path \"auth/token/renew-self\" { capabilities = [\"update\"] }"
    ],
    flatten([
      for p in [for _, v in vault_mount.postgres_db : v.path] : [
        format("path \"sys/mounts/%s\" { capabilities = [\"read\"] }", p),
        format("path \"sys/mounts/%s/*\" { capabilities = [\"read\"] }", p),
        format("path \"%s/config\" { capabilities = [\"list\"] }", p),
        format("path \"%s/config/*\" { capabilities = [\"create\",\"update\",\"read\",\"delete\",\"list\"] }", p),
        format("path \"%s/roles\" { capabilities = [\"list\"] }", p),
        format("path \"%s/roles/*\" { capabilities = [\"create\",\"update\",\"read\",\"delete\",\"list\"] }", p),
        format("path \"sys/leases/revoke/%s/*\" { capabilities = [\"update\"] }", p),
        format("path \"sys/leases/lookup/%s/*\" { capabilities = [\"update\"] }", p),
        format("path \"sys/leases/renew/%s/*\" { capabilities = [\"update\"] }", p)
      ]
    ])
  ))
}

resource "vault_token_auth_backend_role" "manager" {
  role_name           = var.manager_role_name
  orphan              = true
  renewable           = true
  allowed_policies    = [vault_policy.manager.name]
  disallowed_policies = ["default"]
  token_period        = var.manager_token_period
}
