locals {
  kv_policies = [

    # name, access level, mount, and subpaths (["*"] for whole tree)
    { name = "read-apps",  access = "read",  mount = "apps", subpaths = ["*"] },
    { name = "write-apps", access = "write", mount = "apps", subpaths = ["*"] },
    { name = "admin-apps", access = "admin", mount = "apps", subpaths = ["*"] },
  ]
  kv_map = { for p in local.kv_policies : p.name => p }
}

# Loop over each template to create kv policies
resource "vault_policy" "kv" {
  for_each = local.kv_map
  name     = each.value.name
  policy   = templatefile(
    "${path.module}/templates/kv_${each.value.access}.hcl.tmpl",
    { mount = each.value.mount, subpaths = each.value.subpaths }
  )
}
