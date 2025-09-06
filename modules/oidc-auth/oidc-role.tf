# Default role
resource "vault_jwt_auth_backend_role" "default" {
  role_name             = "default-oidc-role"
  backend               = vault_jwt_auth_backend.oidc.path   # creates explicit dependency
  role_type             = "oidc"

  user_claim            = "upn"
  groups_claim          = "groups"
  allowed_redirect_uris = var.redirect_uris

  # bound_audiences     = ["api://your-app-id-uri"]

  token_policies        = ["default"]
  clock_skew_leeway     = 60
}
