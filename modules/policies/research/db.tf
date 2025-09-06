# Policies for dynamic db credential provisioning used within applications
#

## READ
#
# Read policies (dynamic credential generation) are app-specific and located in the app's config

# for `restricted-admin` group
resource "vault_policy" "read-database-mariadb" {
  name   = "read-database-mariadb"
  policy = <<EOT
# [RO] - Dynamic db credentials for applications
#
path "database-mariadb/*"       { capabilities = [ "read" ] }
EOT
}

## WRITE
#
resource "vault_policy" "write-latest-mariadb-credentials" {
  name   = "write-latest-mariadb-credentials"
  policy = <<EOT
# [RW] - Dynamic db credentials for applications
#
path "database-mariadb/static-creds/latest-mariadb-credentials-*" { capabilities = [ "create", "read", "update" ] }
path "database-mariadb/rotate-root/latest-mariadb-credentials-*"  { capabilities = [ "create", "read", "update" ] }
path "database-mariadb/config/latest-mariadb-credentials-*"  { capabilities = [ "create", "read", "update" ] }
EOT
}


## ADMIN
#
resource "vault_policy" "admin-database-mariadb" {
  name   = "admin-database-mariadb"
  policy = <<EOT
# [RO] - Dynamic db credentials for applications
#
path "database-mariadb/*"       { capabilities = [ "create", "read", "update", "delete", "list" ] }
EOT
}
