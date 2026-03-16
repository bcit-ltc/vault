# Configures PKI secrets engine
#
#   - enables dynamic certificate management
#   - see https://learn.hashicorp.com/tutorials/vault/pki-engine-external-ca?in=vault/secrets-management

locals {
  default_10y_in_sec = 315576000
  default_5y_in_sec  = 157680000
  default_3y_in_sec  = 94608000
  default_2y_in_sec  = 63115200
  default_1y_in_sec  = 31536000
  default_90d_in_sec = 7776000
  default_30d_in_sec = 2592000
  default_72h_in_sec = 259200
  default_1d_in_sec  = 86400
  default_4h_in_sec  = 14400
  default_1h_in_sec  = 3600
  default_10m_in_sec = 600
  default_2m_in_sec  = 120
}

# Fetch the SICA Intermediate CA certificate for use as tls_client_ca_file
resource "local_file" "tls_client_ca" {
  content  = vault_pki_secret_backend_root_sign_intermediate.pki_sica_v2_sign_by_pki_pica.certificate_bundle
  filename = "modules/cert-auth/certs/tls_client_ca.pem"
}
