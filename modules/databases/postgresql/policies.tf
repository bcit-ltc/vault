# Read policies per (app, env):
# name:  read-<mount-prefix>-<app>-<env>
# path:  <mount-prefix>-<env>/creds/<app>-<env>

resource "vault_policy" "read_db_app_env" {
  for_each = local.app_env_pairs

  name = format(
    "read-%s-%s-%s",
    var.db_mount_prefix,
    lower(trimspace(each.value.app)),
    each.value.env
  )

  policy = format(
    "path \"%s/creds/%s\" {\n  capabilities = [\"read\"]\n}\n",
    vault_mount.postgres_db[each.value.env].path,
    each.value.role
  )
}

# Admin for Postgres secret backend (create/update roles/config)
locals {
  # Flatten to a simple list of mount path strings
  db_mounts = tolist(values(local.mounts))
}

# Full CRUD over connections/roles, can rotate root, cannot mint creds
resource "vault_policy" "admin_postgresql" {
  name   = "admin-postgresql"
  policy = join("\n", [
    for m in local.db_mounts : <<-EOT
      # ----- Admin for ${m} -----
      # Manage database connections (config) under this mount
      path "${m}/config/*"       { capabilities = ["create","read","update","delete","list"] }

      # Manage dynamic roles
      path "${m}/roles"          { capabilities = ["list"] }
      path "${m}/roles/*"        { capabilities = ["create","read","update","delete","list"] }

      # Manage static roles
      path "${m}/static-roles"   { capabilities = ["list"] }
      path "${m}/static-roles/*" { capabilities = ["create","read","update","delete","list"] }

      # Maintenance: rotate root credentials for connections
      path "${m}/rotate-root/*"  { capabilities = ["update"] }

      # (Optional) Allow tuning of the mount itself
      # path "sys/mounts/${m}"      { capabilities = ["read","update"] }

      # Intentionally DO NOT allow minting credentials:
      # - "${m}/creds/*"
      # - "${m}/static-creds/*"
    EOT
  ])
}

