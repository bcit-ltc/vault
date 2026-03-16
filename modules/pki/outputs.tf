output "pki_pica_mount_path" {
  description = "Mount path for the Primary Intermediate CA (PICA)"
  value       = vault_mount.pki_pica.path
}

output "pki_sica_mount_path" {
  description = "Mount path for the Secondary Intermediate CA (SICA)"
  value       = vault_mount.pki_sica_v2.path
}

output "pki_issue_policy_name" {
  description = "Policy name for issuing certificates"
  value       = vault_policy.pki-issue-certs.name
}

output "pki_admin_policy_name" {
  description = "Policy name for administering PKI secrets engine"
  value       = vault_policy.admin-pki.name
}

# output "sica_ca_certificate" {
#   description = "SICA Intermediate CA certificate (PEM) for use as tls_client_ca_file"
#   value       = data.vault_pki_secret_backend_cert.sica_ca.certificate
# }
