locals {
  file_policies = {
    "admin-system"    = "${path.module}/static-policies/admin_system.hcl"
    "admin-transit"   = "${path.module}/static-policies/admin_transit.hcl"
    "default"         = "${path.module}/static-policies/default.hcl"
    "private-team"    = "${path.module}/static-policies/private_team.hcl"
  }
}

resource "vault_policy" "file_based" {
  for_each = local.file_policies
  name     = each.key
  policy   = file(each.value)
}
