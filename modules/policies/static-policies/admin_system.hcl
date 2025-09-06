# Core System Admin Policy

## Secrets engines (enable/disable/tune)
path "sys/mounts"    { capabilities = ["read"] }
path "sys/mounts/*"  { capabilities = ["sudo","create","read","update","delete","list"] }

## Identity (entities, groups, aliases)
path "identity/*"    { capabilities = ["create","read","update","delete","list"] }

## Auth methods (manage + read)
path "sys/auth"      { capabilities = ["read"] }
path "sys/auth/*"    { capabilities = ["sudo","create","read","update","delete"] }
path "auth/*"        { capabilities = ["sudo","create","read","update","delete","list"] }

## Policies (ACL)
path "sys/policies/acl"    { capabilities = ["list"] }
path "sys/policies/acl/*"  { capabilities = ["create","read","update","delete"] }

# Protect key policies (read-only)
path "sys/policies/acl/admin-system"     { capabilities = ["read"] }
path "sys/policies/acl/private-team"     { capabilities = ["read"] }

## Leases
path "sys/leases/lookup"            { capabilities = ["create","update"] }
path "sys/leases/lookup/*"          { capabilities = ["sudo","list"] }
path "sys/leases/renew"             { capabilities = ["create","update"] }
path "sys/leases/revoke"            { capabilities = ["create","update"] }
path "sys/leases/revoke-force/*"    { capabilities = ["sudo","create","update"] }
path "sys/leases/revoke-prefix/*"   { capabilities = ["sudo","create","update"] }
path "sys/leases/tidy"              { capabilities = ["create","update"] }
path "sys/leases/count"             { capabilities = ["read"] }

## Host/server info
path "sys/health"       { capabilities = ["read"] }
path "sys/leader"       { capabilities = ["read"] }
path "sys/host-info"    { capabilities = ["read"] }
path "sys/seal-status"  { capabilities = ["read"] }
path "sys/config/state" { capabilities = ["read"] }

## Internal/cluster info
path "sys/internal/counters/*"    { capabilities = ["create","read","update"] }
path "sys/internal/specs/openapi" { capabilities = ["sudo","read"] }
path "sys/internal/ui/*"          { capabilities = ["read"] }
path "sys/internal/ui/mounts/*"   { capabilities = ["read"] }

## Audit backends
path "sys/audit"        { capabilities = ["sudo","read","list"] }
path "sys/audit/*"      { capabilities = ["sudo","create","update","delete"] }
path "sys/audit-hash"   { capabilities = ["create","update"] }

## CORS / UI headers
path "sys/config/cors"        { capabilities = ["sudo","create","read","update","delete"] }
path "sys/config/ui/headers"  { capabilities = ["sudo","list"] }
path "sys/config/ui/headers/*"{ capabilities = ["sudo","create","read","update","delete"] }

## Plugins
path "sys/plugins/catalog"    { capabilities = ["read","list"] }
path "sys/plugins/catalog/*"  { capabilities = ["create","read","update","delete","list"] }

## Storage (Raft)
path "sys/storage/raft/*"           { capabilities = ["create","read","update"] }
path "sys/storage/raft/autopilot/*" { capabilities = ["create","read","update"] }

## Seal / Unseal
path "sys/seal"   { capabilities = ["sudo","create","update"] }
path "sys/unseal" { capabilities = ["sudo","create","update"] }

## Token admin (complete surface)
path "auth/token"                 { capabilities = ["sudo","create","update"] }
path "auth/token/create-orphan"   { capabilities = ["sudo","create","update"] }
path "auth/token/accessors"       { capabilities = ["sudo","list"] }
path "auth/token/lookup"          { capabilities = ["sudo","create","update"] }
path "auth/token/lookup-accessor" { capabilities = ["sudo","create","update"] }
path "auth/token/revoke"          { capabilities = ["sudo","create","update"] }
path "auth/token/revoke-accessor" { capabilities = ["sudo","create","update"] }
path "auth/token/revoke-orphan"   { capabilities = ["sudo","create","update"] }

## Capabilities helpers
path "sys/capabilities"          { capabilities = ["create","update"] }
path "sys/capabilities-accessor" { capabilities = ["create","update"] }

## Wrapping
path "sys/wrapping/*" { capabilities = ["create","update"] }

## Crypto tools
path "sys/tools/*" { capabilities = ["create","update"] }
