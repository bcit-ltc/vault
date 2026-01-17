# Embedded policies for kubernetes-auth
#
# Inputs expected by the kubernetes-auth module:
#   - local.app_envs: built from (apps ∪ apps_grouped children) × envs
#   - var.clusters: map(object({ host=string, current_env=string }))
#   - var.acl_policy_mount (or kv_mount): string mount name for app policies (e.g., "apps")
#
# Generates:
#   - read-apps-<app>-<env> policies (scoped read across the app/env path on KV v2)
#   - read-kubernetes and admin-kubernetes policies for auth backends

# Per-app, per-env READ policy (used by k8s auth roles)
# Reuse local.app_envs from locals.tf
resource "vault_policy" "read_app_env" {
  for_each = local.app_envs
  name     = "read-apps-${each.value.app}-${each.value.env}"

  policy = <<EOT
# List & read app secrets at ${var.acl_policy_mount}/${each.value.app}/${each.value.env}
path "${var.acl_policy_mount}/metadata/${each.value.app}/${each.value.env}"   { capabilities = ["list","read"] }
path "${var.acl_policy_mount}/metadata/${each.value.app}/${each.value.env}/*" { capabilities = ["list","read"] }
path "${var.acl_policy_mount}/data/${each.value.app}/${each.value.env}/*"     { capabilities = ["read"] }
EOT
}

# Read-only visibility into Kubernetes auth backends (for debugging)
resource "vault_policy" "read_kubernetes" {
  name   = "read-kubernetes"
  policy = <<EOT
# List and read k8s roles (but not modify)
path "auth/kubernetes*/role"    { capabilities = ["list"] }
path "auth/kubernetes*/role/*"  { capabilities = ["read","list"] }
EOT
}

# Admin for Kubernetes auth (create/update roles/config)
resource "vault_policy" "admin_kubernetes" {
  name   = "admin-kubernetes"
  policy = <<EOT
# Manage Kubernetes auth config and roles
path "auth/kubernetes*"  { capabilities = ["create","read","update"] }
path "auth/kubernetes*"    { capabilities = ["list"] }
path "auth/kubernetes*"  { capabilities = ["create","read","update","delete","list"] }
EOT
}
