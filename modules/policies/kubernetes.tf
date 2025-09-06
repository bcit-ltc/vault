# [RO]
resource "vault_policy" "read_kubernetes" {
  name   = "read-kubernetes"
  policy = <<EOT
# [RO] Kubernetes auth config and roles
path "auth/kubernetes*/config"  { capabilities = ["read"] }
path "auth/kubernetes*/role"    { capabilities = ["list"] }
path "auth/kubernetes*/role/*"  { capabilities = ["read","list"] }
EOT
}

# [ADMIN]
resource "vault_policy" "admin_kubernetes" {
  name   = "admin-kubernetes"
  policy = <<EOT
# Manage Kubernetes auth config and roles
path "auth/kubernetes*/config"  { capabilities = ["create","read","update"] }
path "auth/kubernetes*/role"    { capabilities = ["list"] }
path "auth/kubernetes*/role/*"  { capabilities = ["create","read","update","delete","list"] }
EOT
}
