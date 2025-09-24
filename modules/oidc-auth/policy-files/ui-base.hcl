path "sys/capabilities-self"  { capabilities = ["update"] }
path "auth/token/lookup-self" { capabilities = ["read"] }
path "auth/token/renew-self"  { capabilities = ["update"] }
path "auth/token/revoke-self" { capabilities = ["update"] }

# Also let users list mounts and read mount metadata
path "sys/mounts"               { capabilities = ["read"] }
path "sys/mounts/*"             { capabilities = ["read"] }
