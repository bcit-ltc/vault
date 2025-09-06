# Derive env → backend/cluster/host from new schema
locals {

  # From clusters = { prod-03 = {host, current_env}, prod-02 = {...}, ... }
  envs           = distinct([for cname, c in var.clusters : c.current_env])

  # Backends are named kubernetes-{env}
  env_to_backend = { for e in local.envs : e => "kubernetes-${e}" }

  # Assume each env is uniquely assigned to one cluster
  env_to_cluster = {
    for cname, c in var.clusters : c.current_env => cname
  }
  env_to_host = {
    for cname, c in var.clusters : c.current_env => c.host
  }
}

# Read cluster auth materials (one read per cluster)
# KV v2 + generic_secret:
#   Use the logical path WITHOUT "/data/".
#   Provider rewrites internally to ".../data/...".
#   e.g., ltc-infrastructure/clusters/prod-02
data "vault_generic_secret" "k8s_auth_materials" {
  for_each = var.clusters
  path     = "ltc-infrastructure/clusters/${each.key}"
}

# Handle both shapes returned by the provider:
# - KV v2 flattened: s.data["ca_pem"]
# - KV v2 nested:    s.data["data"]["ca_pem"]
locals {
  ca_pem_by_cluster = {
    for cname, s in data.vault_generic_secret.k8s_auth_materials :
    cname => coalesce(
      try(s.data["data"]["ca_pem"], null),
      try(s.data["ca_pem"], null)
    )
  }
  token_by_cluster = {
    for cname, s in data.vault_generic_secret.k8s_auth_materials :
    cname => coalesce(
      try(s.data["data"]["token_reviewer_jwt"], null),
      try(s.data["token_reviewer_jwt"], null)
    )
  }
}

# Backends: one per ENV, named kubernetes-{env}
resource "vault_auth_backend" "k8s_backends" {
  for_each    = local.env_to_backend         # keys are env names only
  type        = "kubernetes"
  path        = each.value                   # e.g. "kubernetes-latest"
  description = "K8s auth for ${each.key}"
}

# Backend configs: one per ENV (sourced from mapped cluster)
resource "vault_kubernetes_auth_backend_config" "per_env" {
  for_each               = local.env_to_backend
  backend                = each.value
  disable_iss_validation = true

  kubernetes_ca_cert = local.ca_pem_by_cluster[local.env_to_cluster[each.key]]

  # Optional: omit this if you don't want it in TF state
  token_reviewer_jwt = local.token_by_cluster[local.env_to_cluster[each.key]]
  kubernetes_host    = local.env_to_host[each.key]

  depends_on = [vault_auth_backend.k8s_backends]
}

# Roles: apps × envs
locals {
  app_envs = {
    for combo in flatten([
      for app in var.apps : [
        for env, backend in local.env_to_backend : {
          key     = "${app}.${env}"
          app     = app
          env     = env
          backend = backend
        }
      ]
    ]) : combo.key => combo
  }
}

resource "vault_kubernetes_auth_backend_role" "app_roles" {
  for_each = local.app_envs

  backend                           = each.value.backend
  role_name                         = "${each.value.app}-vault-auth-${each.value.env}"
  bound_service_account_namespaces  = ["${each.value.app}"]
  bound_service_account_names       = [each.value.app]
  audience                          = each.value.env

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs

  token_policies = concat(
    var.common_policies,
    [ "read-apps-${each.value.app}-${each.value.env}" ]
  )

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env,
  ]
}
