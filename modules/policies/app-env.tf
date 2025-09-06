# Generate a map of all app/environment combinations for policy creation.
locals {
  app_envs = {
    for combo in flatten([
      for app in var.apps : [
        for env in var.envs : {
          key = "${app}.${env}"
          app = app
          env = env
        }
      ]
    ]) : combo.key => combo
  }
}

resource "vault_policy" "read_app_env" {
  for_each = local.app_envs
  name     = "read-apps-${each.value.app}-${each.value.env}"
  policy   = <<EOT
# [RO] ${each.value.app} (${each.value.env}) — KV v2
path "${var.kv_mount}/metadata/${each.value.app}/${each.value.env}"     { capabilities = ["list"] }
path "${var.kv_mount}/metadata/${each.value.app}/${each.value.env}/*"   { capabilities = ["list"] }
path "${var.kv_mount}/data/${each.value.app}/${each.value.env}/*"       { capabilities = ["read"] }
EOT
}

# Allow approle to generate a secretID
resource "vault_policy" "admin-approle-get-secretid" {
  name   = "admin-approle-get-secretid"
  policy = <<EOT
# Allow approle to generate a secretID
path "auth/approle/role/+/secret-id"  { capabilities = [ "update" ] }
EOT
}

# Allow approle to view its own token
resource "vault_policy" "token-lookup-self" {
  name   = "token-lookup-self"
  policy = <<EOT
## Token lookup
#
path "auth/token/lookup-self"   { capabilities = [ "read" ] }
EOT
}