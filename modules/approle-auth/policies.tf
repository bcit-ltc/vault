# AppRole auth method configuration - Create and manage roles
resource "vault_policy" "admin-approle" {
  name   = "admin-approle"
  policy = <<EOT
# AppRole auth method configuration - Create and manage roles
path "auth/approle/*" { capabilities = ["create","read","update","delete","list"] }
EOT
}

# Allow Ansible to generate an approle secretID
resource "vault_policy" "admin-ansible-get-secretid" {
  name   = "admin-ansible-get-secretid"
  policy = <<EOT
# Allow Ansible to generate AppRole SecretIDs for selected roles
%{ for r in var.approle_secretid_roles ~}
path "auth/approle/role/${r}/secret-id" { capabilities = ["update"] }
%{ endfor ~}
EOT
}
