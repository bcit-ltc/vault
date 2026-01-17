# Login to Vault via Entra ID (OIDC)
resource "vault_jwt_auth_backend" "oidc" {
  path               = var.oidc_auth_path
  type               = "oidc"
  description        = "Login with Azure Entra ID (OIDC)"
  oidc_discovery_url = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = var.oidc_client_secret
  default_role       = "default"
}

resource "vault_jwt_auth_backend_role" "default" {
  backend               = vault_jwt_auth_backend.oidc.path
  role_name             = "default"
  role_type             = "oidc"
  user_claim            = "oid"
  # groups_claim        = "groups"
  oidc_scopes           = ["profile", "email"]

  claim_mappings = {
    email              = "email"
    preferred_username = "preferred_username"
    upn                = "upn"
    name               = "name"
  }

  allowed_redirect_uris = var.allowed_redirect_uris
  token_policies        = [vault_policy.ui_base.name]
}

# Vault as OIDC Provider (for downstream apps)
resource "vault_identity_oidc_scope" "groups" {
  name        = "groups"
  description = "List of Vault Identity group names."
  template    = "{\"groups\": {{identity.entity.groups.names}}}"
}

resource "vault_identity_oidc_scope" "user" {
  name        = "user"
  description = "Vault Identity entity name."
  template    = "{\"username\": {{identity.entity.name}}}"
}

# Create an assignment per client so toggling allow_all does not destroy resources
resource "vault_identity_oidc_assignment" "client" {
  for_each = var.clients

  name       = "${var.provider_name}-${each.key}"
  entity_ids = try(each.value.assignment_entity_ids, [])
  group_ids  = try(each.value.assignment_group_ids, [])
}

resource "vault_identity_oidc_client" "client" {
  for_each = var.clients

  name          = each.key
  redirect_uris = each.value.redirect_uris

  # If allow_all = true, the assignment exists but isn't referenced
  assignments = try(each.value.allow_all, false) ? ["allow_all"] : [vault_identity_oidc_assignment.client[each.key].name]

  id_token_ttl     = try(each.value.id_token_ttl, 2400)
  access_token_ttl = try(each.value.access_token_ttl, 7200)
}

resource "vault_identity_oidc_provider" "this" {
  name          = var.provider_name
  https_enabled = true
  issuer_host   = var.issuer_host

  allowed_client_ids = sort([
    for c in vault_identity_oidc_client.client : c.client_id
  ])

  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.user.name,
  ]
}
