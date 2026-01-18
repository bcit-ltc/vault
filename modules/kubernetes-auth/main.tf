# Kubernetes auth backends: one per ENV (named kubernetes-{env})
resource "vault_auth_backend" "k8s_backends" {
  for_each    = local.env_to_backend         # keys are envs
  type        = "kubernetes"
  path        = each.value                   # e.g., "kubernetes-stable"
  description = "K8s auth for ${each.key}"
}

# Backend configs: one per ENV (sourced from mapped cluster)
resource "vault_kubernetes_auth_backend_config" "per_env" {
  for_each               = local.env_to_backend
  backend                = each.value
  disable_iss_validation = true

  kubernetes_ca_cert = local.ca_pem_by_cluster[local.env_to_cluster[each.key]]
  token_reviewer_jwt = local.token_by_cluster[local.env_to_cluster[each.key]]
  kubernetes_host    = local.env_to_host[each.key]

  depends_on = [vault_auth_backend.k8s_backends]
}

# Roles: apps × envs
resource "vault_kubernetes_auth_backend_role" "app_roles" {
  for_each = local.app_envs

  backend   = each.value.backend
  role_name = "${each.value.app}-vault-auth"

  bound_service_account_namespaces = [lookup(local.app_parent_map, each.value.app, each.value.app)]
  bound_service_account_names      = [each.value.app]
  audience                         = each.value.env

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs

  token_policies = concat(
    var.common_policies,
    ["read-apps-${each.value.app}-${each.value.env}"],
    ["read-postgresql-${each.value.app}-${each.value.env}"],
    lookup(local.app_to_extra_policies, each.value.app, [])
  )

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env,
  ]
}

# Roles for postgres: one role per ENV: postgres-vault-auth
resource "vault_kubernetes_auth_backend_role" "postgres_init" {
  for_each = local.env_to_backend

  backend   = each.value                                 # e.g., "kubernetes-stable"
  role_name = "postgres-vault-auth"          # e.g., postgres-vault-auth-stable

  bound_service_account_namespaces  = ["postgres"]
  bound_service_account_names       = ["pg-core"]
  audience                          = each.key            # e.g., "stable", "latest"

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs
  token_policies    = ["read-ltc-infrastructure-postgres"]

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env, # ensure backend is configured
  ]
}

# Roles for flux: one role per ENV: flux-vault-auth
resource "vault_kubernetes_auth_backend_role" "flux" {
  for_each = local.env_to_backend

  backend   = each.value                                 # e.g., "kubernetes-stable"
  role_name = "flux-vault-auth"              # e.g., flux-vault-auth-stable

  bound_service_account_namespaces  = ["flux-system"]
  bound_service_account_names       = ["flux-service-account"]
  audience                          = each.key            # e.g., "stable", "latest"

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs
  token_policies    = ["read-ltc-infrastructure-ssl-certificates"]

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env, # ensure backend is configured
  ]
}

# Roles for longhorn-azblob: one role per ENV: longhorn-azblob-vault-auth
resource "vault_kubernetes_auth_backend_role" "longhorn-azblob" {
  for_each = local.env_to_backend

  backend   = each.value                                 # e.g., "kubernetes-stable"
  role_name = "longhorn-azblob-vault-auth"              # e.g., longhorn-azblob-vault-auth-stable

  bound_service_account_namespaces  = ["longhorn-system"]
  bound_service_account_names       = ["longhorn-azblob-sa"]
  audience                          = each.key            # e.g., "stable", "latest"

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs
  token_policies    = ["read-ltc-infrastructure-longhorn-azblob-credentials"]

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env, # ensure backend is configured
  ]
}

# Roles for tailscale-operator: one role per ENV: tailscale-operator-vault-auth
resource "vault_kubernetes_auth_backend_role" "tailscale-operator" {
  for_each = local.env_to_backend

  backend   = each.value                                  # e.g., "kubernetes-stable"
  role_name = "tailscale-operator-vault-auth" # e.g., tailscale-operator-vault-auth-stable

  bound_service_account_namespaces  = ["tailscale"]
  bound_service_account_names       = ["tailscale-operator-oauth-sa"]
  audience                          = each.key            # e.g., "stable", "latest"

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs
  token_policies    = ["read-ltc-infrastructure-tailscale-oauth-credentials"]

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env, # ensure backend is configured
  ]
}

# Additional role for github private tokens
locals {
  # For each app, build a list of extra policies to add (empty if not targeted)
  app_to_extra_policies = {
    for a in local.all_apps :
    a => (contains(var.private_apps, a) ? [var.github_private_tokens_policy] : [])
  }
}

