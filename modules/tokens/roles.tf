# Token roles → policies, periods, and CIDR binding
locals {
  token_roles = {

    # Allows service to call approle SecretID endpoints (policy must permit those paths)
    "approle-token-create" = {
      period   = local.ttl_4h
      policies = ["admin-approle-get-secretid"]
      cidrs    = var.token_bound_cidrs
    }

    # Metrics admin (no CIDR binding here by design)
    "metrics-token-create" = {
      period   = local.ttl_30d
      policies = ["admin-metrics"]
      cidrs    = []
    }

    # SOPS usage: prefer the least-privilege transit policy name
    "use-transit-gitops-key" = {
      period   = local.ttl_30d
      policies = ["default", "use-transit-gitops-key"]
      cidrs    = var.token_bound_cidrs
    }
  }
}

# Generate vault token roles
resource "vault_token_auth_backend_role" "roles" {
  for_each = local.token_roles

  role_name            = each.key
  allowed_policies     = each.value.policies
  disallowed_policies  = ["default"]   # keep tokens policy-scoped; no implicit 'default'
  orphan               = true          # no parent; avoids cascading revocation issues
  renewable            = true          # allow renewal (bounded by periodic semantics)
  token_period         = each.value.period
  token_bound_cidrs    = each.value.cidrs
}
