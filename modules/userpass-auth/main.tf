# Userpass auth method
resource "vault_auth_backend" "userpass" {
  type          = "userpass"
  description   = "Authenticate using a username/password pair"
}
