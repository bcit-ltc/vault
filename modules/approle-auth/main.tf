resource "vault_auth_backend" "auth_approle" {
  type        = "approle"
  path        = "approle"
  description = "Authenticate with pre-configured apps"
}
