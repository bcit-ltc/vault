locals {
  envs = ["latest", "stable"]

  infrastructure_services = {

    # Env-scoped
    # bcit-active-directory   = { subpath = "bcit-active-directory", envs = local.envs }
    # keycloak                = { subpath = "keycloak/+",      envs = local.envs }
    # aws-credentials         = { subpath = "aws-credentials", envs = local.envs }

    # Non-env
    flux                    = { subpath = "flux",             envs = [] }
    inventory               = { subpath = "inventory",        envs = [] }
    ssl-certificates        = { subpath = "ssl-certificates", envs = [] }
  }

  infrastructure_env_policies = {
    for combo in flatten([
      for svc_name, svc in local.infrastructure_services : length(svc.envs) > 0 ? [
        for env in svc.envs : {
          name = "read-ltc-infrastructure-${svc_name}-${env}"
          sub  = svc.subpath
          env  = env
        }
      ] : []
    ]) : combo.name => combo
  }

  infrastructure_fixed_policies = {
    for svc_name, svc in local.infrastructure_services :
    "read-ltc-infrastructure-${svc_name}" => { sub = svc.subpath }
    if length(svc.envs) == 0
  }
}

resource "vault_policy" "ltc_infrastructure_read_env" {
  for_each = local.infrastructure_env_policies
  name     = each.key
  policy   = <<EOT
# [RO] ltc-infrastructure ${each.value.sub}/${each.value.env} — KV v2
path "ltc-infrastructure/metadata/${each.value.sub}/${each.value.env}"     { capabilities = ["list"] }
path "ltc-infrastructure/metadata/${each.value.sub}/${each.value.env}/*"   { capabilities = ["list"] }
path "ltc-infrastructure/data/${each.value.sub}/${each.value.env}/*"       { capabilities = ["read"] }
EOT
}

resource "vault_policy" "ltc_infrastructure_read" {
  for_each = local.infrastructure_fixed_policies
  name     = each.key
  policy   = <<EOT
# [RO] ltc-infrastructure ${each.value.sub} — KV v2
path "ltc-infrastructure/metadata/${each.value.sub}"     { capabilities = ["list"] }
path "ltc-infrastructure/metadata/${each.value.sub}/*"   { capabilities = ["list"] }
path "ltc-infrastructure/data/${each.value.sub}/*"       { capabilities = ["read"] }
EOT
}

# resource "vault_policy" "read_ltc_infrastructure" {
#   name   = "read-ltc-infrastructure"
#   policy = <<EOT
# # [RO] broad read on the mount (KV v2)
# path "ltc-infrastructure/metadata"     { capabilities = ["list"] }
# path "ltc-infrastructure/metadata/*"   { capabilities = ["list"] }
# path "ltc-infrastructure/data/*"       { capabilities = ["read"] }
# EOT
# }

resource "vault_policy" "write_ltc_infrastructure" {
  name   = "write-ltc-infrastructure"
  policy = <<EOT
# [WR] broad write (KV v2)
path "ltc-infrastructure/metadata"     { capabilities = ["list"] }
path "ltc-infrastructure/metadata/*"   { capabilities = ["list"] }
path "ltc-infrastructure/data/*"       { capabilities = ["create","update","read"] }
EOT
}

resource "vault_policy" "admin_ltc_infrastructure" {
  name   = "admin-ltc-infrastructure"
  policy = <<EOT
# [ADMIN] full control (KV v2)
path "ltc-infrastructure/metadata/*"   { capabilities = ["create","read","update","delete","list"] }
path "ltc-infrastructure/data/*"       { capabilities = ["create","read","update","delete","list"] }

# KV v2 version management
path "ltc-infrastructure/delete/*"     { capabilities = ["update"] }
path "ltc-infrastructure/destroy/*"    { capabilities = ["update"] }
path "ltc-infrastructure/undelete/*"   { capabilities = ["update"] }
EOT
}
