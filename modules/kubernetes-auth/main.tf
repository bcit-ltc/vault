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
  role_name = "${each.value.app}-vault-auth-${each.value.env}"

  # Bind to parent namespace if defined; otherwise bind to the app's own namespace
  bound_service_account_namespaces = [lookup(local.app_parent_map, each.value.app, each.value.app)]
  bound_service_account_names      = [each.value.app]
  audience                         = each.value.env

  token_ttl         = var.token_ttl_seconds
  token_bound_cidrs = var.token_bound_cidrs

  token_policies = concat(
    var.common_policies,
    ["read-apps-${each.value.app}-${each.value.env}"],
    ["read-db-${each.value.app}"],

  )

  depends_on = [
    vault_auth_backend.k8s_backends,
    vault_kubernetes_auth_backend_config.per_env,
  ]
}
