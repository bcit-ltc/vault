# Embedded policies for transit module

# General "use" policy for transit and sops engines
resource "vault_policy" "use_transit" {
  name   = "use-transit"
  policy = <<EOT
# Encrypt/decrypt endpoints (no key export)
path "transit/encrypt/*" { capabilities = ["update"] }
path "transit/decrypt/*" { capabilities = ["update"] }
path "sops/encrypt/*"    { capabilities = ["update"] }
path "sops/decrypt/*"    { capabilities = ["update"] }
EOT
}

# Admin policy for transit (non-export) + sops
resource "vault_policy" "admin_transit" {
  name   = "admin-transit"
  policy = <<EOT
# CRUD on keys (create, read metadata, tune, delete)
path "transit/keys/*" { capabilities = ["create","read","update","delete","list"] }
path "sops/keys/*"    { capabilities = ["create","read","update","delete","list"] }

# Rotate and per-key config
path "transit/keys/*/rotate" { capabilities = ["update"] }
path "sops/keys/*/rotate"    { capabilities = ["update"] }

path "transit/keys/*/config" { capabilities = ["create","update","read"] }
path "sops/keys/*/config"    { capabilities = ["create","update","read"] }

# Intentionally omit export endpoints for safety.
EOT
}
