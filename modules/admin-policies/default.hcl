# Default policies

## Token self-ops
path "auth/token/lookup-self" { capabilities = ["read"] }
path "auth/token/renew-self"  { capabilities = ["update"] }
path "auth/token/revoke-self" { capabilities = ["update"] }
path "sys/capabilities-self"  { capabilities = ["create","update"] }

## Per-token private storage
path "cubbyhole"   { capabilities = ["list"] }
path "cubbyhole/*" { capabilities = ["create","read","update","delete","list"] }

## System tools (hash, random, etc.)
path "sys/tools/*" { capabilities = ["create","update"] }

## Useful for UIs
path "sys/internal/ui/resultant-acl" { capabilities = ["read"] }

# Read your own identity info
path "identity/entity/name/{{identity.entity.name}}" {
capabilities = ["read"]
}

# Lookup your entity ID
path "identity/entity/id/{{identity.entity.id}}" {
capabilities = ["read"]
}
