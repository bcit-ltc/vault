# Embedded policies for KV engines (apps + external)

locals {
  kv_policies = [
    # name, access level, mount, subpaths
    { name = "read-apps",   access = "read",  mount = "apps",    subpaths = ["*"] },
    { name = "admin-apps",  access = "admin", mount = "apps",    subpaths = ["*"] },
    { name = "write-external", access = "write", mount = "external", subpaths = ["*"] },
    { name = "admin-external", access = "admin", mount = "external", subpaths = ["*"] },
    { name = "read-ltc-infrastructure-inventory", access = "read", mount = "ltc-infrastructure", subpaths = ["inventory"] },
    { name = "read-ltc-infrastructure-ssl-certificates", access = "read", mount = "ltc-infrastructure", subpaths = ["ssl-certificates/*"] },
    { name = "write-ltc-infrastructure", access = "write", mount = "ltc-infrastructure", subpaths = ["*"] },
    { name = "admin-ltc-infrastructure", access = "admin", mount = "ltc-infrastructure", subpaths = ["*"] },
    { name = "read-ltc-infrastructure-flux-github-webhook-token", access = "read", mount = "ltc-infrastructure", subpaths = ["flux/github-webhook-token*"] },
  ]
}

resource "vault_policy" "kv" {
  for_each = { for p in local.kv_policies : p.name => p }

  name   = each.value.name
  policy = templatefile("${path.module}/templates/${each.value.access}.hcl.tmpl", {
    mount    = each.value.mount
    subpaths = each.value.subpaths
  })
}

# Read-only policy for postgres init secrets (KV v2)
resource "vault_policy" "read_postgres_init" {
  name   = "read-ltc-infrastructure-postgres"
  policy = <<-EOT
    # List & read postgres init secrets under ltc-infrastructure/postgres/*
    path "ltc-infrastructure/metadata/postgres"     { capabilities = ["list", "read"] }
    path "ltc-infrastructure/metadata/postgres/*"   { capabilities = ["list", "read"] }
    path "ltc-infrastructure/data/postgres/*"       { capabilities = ["read"] }
  EOT
}
