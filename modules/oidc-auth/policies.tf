data "vault_auth_backend" "oidc" {
  path = vault_jwt_auth_backend.oidc.path
}

resource "vault_policy" "user_by_upn" {
  name   = "user-by-upn"
  policy = templatefile("${path.module}/policy-files/user-by-upn.hcl.tmpl", {
    accessor = data.vault_auth_backend.oidc.accessor
  })
}

resource "vault_policy" "ui_base" {
  name   = "ui-base"
  policy = file("${path.module}/policy-files/ui-base.hcl")
}
