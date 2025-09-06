# Generate least-privilege transit usage policies per key.
locals {
  transit_use = {

    # Encrypt/decrypt/rewrap only on the sops mount:
    "use-transit-gitops-key" = {
      mount = "sops"
      key   = "gitops-key"
      allow = ["encrypt","decrypt","rewrap"]
    }

    # Sign/verify only (ECDSA P-256), on the transit mount:
    "use-transit-bcit-ltc-sign-key" = {
      mount = "transit"
      key   = "bcit-ltc-sign-key"
      allow = ["sign","verify"]
    }

    # Example for later:
    # "use_transit_attestation_key" = { mount = "transit", key = "attest_key", allow = ["sign","verify"] }
  }
}

resource "vault_policy" "use_transit" {
  for_each = local.transit_use
  name     = each.key

  policy = templatefile(
    "${path.module}/templates/transit_use.hcl.tmpl",
    {
      mount = each.value.mount
      key   = each.value.key
      allow = each.value.allow
    }
  )
}
