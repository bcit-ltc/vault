# Userpass auth method configuration - Allow users to update their passwords
locals {
  policies = {
    admin-userpass = {
      template_path = "${path.module}/templates/admin_userpass.hcl.tmpl"
      params = {
        userpass_mount = var.userpass_mount
      }
    }
    write-userpass = {
      template_path = "${path.module}/templates/write_userpass_self.hcl.tmpl"
      params = {
        userpass_mount    = var.userpass_mount
        userpass_accessor = var.userpass_accessor
      }
    }
  }
}

resource "vault_policy" "from_templates" {
  for_each = local.policies
  name     = each.key                      # "admin-userpass"
  policy   = templatefile(each.value.template_path, each.value.params)
}
