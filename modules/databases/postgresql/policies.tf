# One read policy per DB role in var.postgresql_databases
# Build (db × env) pairs for per-env policy names
locals {
  db_env_pairs = {
    for p in setproduct(var.postgresql_databases, var.envs) :
    "${p[0]}-${p[1]}" => { db = p[0], env = p[1] }
  }
}

# # One READ policy per (db, env): read-db-<db>-<env>
# resource "vault_policy" "app_db_read" {
#   for_each = local.db_env_pairs

#   name   = "read-db-${each.value.db}-${each.value.env}"
#   policy = <<-EOT
#   # Allow dynamic DB creds for role "${each.value.db}"
#   path "${var.db_mount_path}/creds/${each.value.db}" {
#     capabilities = ["read"]
#   }
#   EOT
# }

# (Optional) admin policy for managing the database engine (unchanged)
resource "vault_policy" "admin_postgresql" {
  name   = "admin-postgresql"
  policy = <<-EOT
  path "${var.db_mount_path}/*" {
    capabilities = ["create","read","update","delete","list"]
  }
  EOT
}

# Flat (env-less) policy per DB so kubernetes-auth roles that expect "read-db-<app>" work
resource "vault_policy" "read_db_app" {
  for_each = toset(var.postgresql_databases)

  name   = "read-db-${each.value}"
  policy = <<-EOT
  path "${var.db_mount_path}/creds/${each.value}" {
    capabilities = ["read"]
  }
  EOT
}
