# Load module-local YAML (single source of truth)
locals {
  config = yamldecode(file("${path.module}/approle-roles.yaml"))
}

# Create all AppRole roles from the YAML
resource "vault_approle_auth_backend_role" "app_roles" {
  for_each = local.config.approle_roles

  backend                 = vault_auth_backend.auth_approle.path
  role_name               = each.key
  token_policies          = each.value.token_policies
  token_no_default_policy = true

  token_ttl         = local.config.token_ttl_seconds
  token_max_ttl     = local.config.token_max_ttl_seconds
  secret_id_ttl     = local.config.secret_id_ttl_seconds
  token_bound_cidrs = local.config.token_bound_cidrs
}

# Expose RoleIDs (NOT SecretIDs)
data "vault_approle_auth_backend_role_id" "role_id" {
  for_each = local.config.approle_roles
  backend  = vault_auth_backend.auth_approle.path
  role_name = each.key
}

output "role_ids" {
  description = "Map of approle role_name → RoleID"
  value       = { for k, v in data.vault_approle_auth_backend_role_id.role_id : k => v.role_id }
}
