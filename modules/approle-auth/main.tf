# AppRole auth backend
resource "vault_auth_backend" "approle" {
  type        = "approle"
  path        = var.auth_path
  description = "AppRole authentication"
}

# AppRole roles (one per map entry)
resource "vault_approle_auth_backend_role" "roles" {
  for_each = var.approle_roles

  backend                 = vault_auth_backend.approle.path
  role_name               = each.key
  token_policies          = each.value.token_policies
  token_no_default_policy = try(each.value.token_no_default_policy, var.token_no_default_policy)

  token_ttl     = try(each.value.token_ttl_seconds,     var.token_ttl_seconds)
  token_max_ttl = try(each.value.token_max_ttl_seconds, var.token_max_ttl_seconds)

  token_bound_cidrs = try(each.value.token_bound_cidrs, var.token_bound_cidrs)
}

# Expose RoleIDs (never SecretIDs)
data "vault_approle_auth_backend_role_id" "role_ids" {
  for_each = var.approle_roles
  backend  = vault_auth_backend.approle.path
  role_name = each.key
}

