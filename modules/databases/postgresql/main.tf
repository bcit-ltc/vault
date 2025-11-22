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
    username                = var.admin_username
    password                = var.admin_password
    password_authentication = "scram-sha-256"
    max_open_connections    = 8
    max_connection_lifetime = 300
  }
}

# One dynamic role per (app, env)
#
# Contract with CNPG + bootstrap job:
# - Each app has:
#     DB:        <app_pg>            (e.g. "qcon_api")
#     APP_ROLE:  <app_pg><suffix>    (e.g. "qcon_api_app")
#   created by the bootstrap job using db_root_owner as the DB owner.
#
# - These dynamic roles are short-lived login roles that:
#   - are granted into APP_ROLE
#   - have search_path set to the app schema for the app DB
resource "vault_database_secret_backend_role" "postgres_role" {
  for_each    = local.app_env_pairs

  backend     = vault_mount.postgres_db[each.value.env].path
  name        = each.value.role
  db_name     = vault_database_secret_backend_connection.postgres_connection[each.value.env].name
  default_ttl = var.default_ttl_seconds
  max_ttl     = var.max_ttl_seconds

  # On first issue: create a short-lived login role and add it to the app group role
  creation_statements = [
    # Short-lived login, expiry tied to Vault lease
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    # Membership in app group role, e.g. qcon_api_app
    "GRANT ${each.value.app_pg}${var.app_role_suffix} TO \"{{name}}\";",
    # Make sure search_path matches the app schema in the app database
    "ALTER ROLE \"{{name}}\" IN DATABASE ${each.value.app_pg} SET search_path = ${each.value.app_pg}, public;"
  ]

  # On lease renewal: keep Postgres role metadata aligned with the renewed lease
  renew_statements = [
    # Refresh password + VALID UNTIL to match renewed Vault lease
    "ALTER ROLE \"{{name}}\" WITH PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    # (Re)assert search_path, in case it was changed out-of-band
    "ALTER ROLE \"{{name}}\" IN DATABASE ${each.value.app_pg} SET search_path = ${each.value.app_pg}, public;"
  ]

  # On revoke/expiry: cleanly drop the short-lived login role
  revocation_statements = [
    # Kill any active sessions using this role before dropping it
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = '{{name}}';",
    # Remove membership then drop the role
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
