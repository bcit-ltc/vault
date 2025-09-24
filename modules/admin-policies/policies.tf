resource "vault_policy" "admin_system" {
  name   = "admin-system"
  policy = file("${path.module}/admin_system.hcl")
}

resource "vault_policy" "default" {
  name   = "default"
  policy = file("${path.module}/default.hcl")

  lifecycle {
    prevent_destroy = true
  }
}

# Enable auditing of write transactions to file (owned by `vault` user)
resource "vault_audit" "audit-log" {
  type        = "file"
  description = "file audit log"
  options     = { file_path = "/var/log/vault/audit.log" }
  lifecycle   { prevent_destroy = true }
}

# Administer metrics
resource "vault_policy" "admin-metrics" {
  name   = "admin-metrics"
  policy = <<EOT
# Administer metrics

path "sys/metrics"   { capabilities = [ "read", "list" ] }
EOT
}
