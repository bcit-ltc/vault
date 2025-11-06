resource "vault_mount" "github" {
  path = "github"
  type = "github"
}

resource "vault_generic_endpoint" "github-config" {
  path = "${vault_mount.github.path}/config"
  data_json = jsonencode({
    app_id = ""
    ins_id = ""
  })
  ignore_absent_fields = true
}


data "vault_policy_document" "foo" {
  rule {
    path                = "${vault_mount.github.path}/token"
    capabilities        = ["update"]
    required_parameters = ["permissions", "repository_ids"]

    allowed_parameter {
      key   = "repository_ids"
      value = ["..."]
    }

    allowed_parameter {
      key   = "permissions"
      value = ["contents=write"]
    }
  }

}