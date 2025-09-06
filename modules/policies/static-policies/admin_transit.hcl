# Transit admin policy (transit + sops mounts)

# List keys
path "transit/keys" { capabilities = ["list"] }
path "sops/keys"    { capabilities = ["list"] }

# CRUD on keys (create, read metadata, tune, delete)
path "transit/keys/*" { capabilities = ["create","read","update","delete","list"] }
path "sops/keys/*"    { capabilities = ["create","read","update","delete","list"] }

# Rotate and per-key config
path "transit/keys/*/rotate" { capabilities = ["update"] }
path "sops/keys/*/rotate"    { capabilities = ["update"] }

path "transit/keys/*/config" { capabilities = ["create","update","read"] }
path "sops/keys/*/config"    { capabilities = ["create","update","read"] }

# Intentionally *not* granting export endpoints:
# path "transit/export/*" / "sops/export/*" are omitted for safety.
