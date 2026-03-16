# PKI certificate issuer and admin policies for PKI module

## WRITE
resource "vault_policy" "pki-issue-certs" {
  name   = "pki-issue-certs"
  policy = <<EOT
# PKI certificate issuer - Secondary Intermediate Certificate Authority permissions
#
path "pki/sica/+/ca"        { capabilities = [ "read" ] }
path "pki/sica/+/certs"     { capabilities = [ "list" ] }
path "pki/sica/+/issue/*"   { capabilities = [ "update" ] }

## Token lookup/renew
path "auth/token/lookup-self"   { capabilities = [ "read" ] }
path "auth/token/renew"         { capabilities = [ "update" ] }
EOT
}

## ADMIN
resource "vault_policy" "admin-pki" {
  name   = "admin-pki"
  policy = <<EOT
## Administer pki secrets engine for both PICA and SICA mounts

# Primary Intermediate CA (PICA)
path "pki/pica/*"         { capabilities = [ "sudo", "create", "read", "update", "delete", "list" ] }
path "sys/mounts/pki/pica" { capabilities = [ "create", "read", "update", "delete", "list" ] }

# Secondary Intermediate CA (SICA)
path "pki/sica/v2/*"         { capabilities = [ "sudo", "create", "read", "update", "delete", "list" ] }
path "sys/mounts/pki/sica/v2" { capabilities = [ "create", "read", "update", "delete", "list" ] }
EOT
}
