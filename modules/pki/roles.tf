# PKI engine roles - enables certificates to be issued

## Client certs limited to allowed_domains
resource "vault_pki_secret_backend_role" "pki" {
  backend            = vault_mount.pki_sica_v2.path
  name               = "pki"
  ttl                = local.default_72h_in_sec
  max_ttl            = local.default_1y_in_sec
  allow_localhost    = false
  allow_ip_sans      = false
  allow_subdomains   = true
  server_flag        = false
  client_flag        = true
  allow_glob_domains = false
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  allowed_domains    = var.allowed_domains
  country            = [var.country]
  locality           = [var.locality]
  province           = [var.province]
  organization       = [var.organization]
}

## Server certs limited to allowed_domains
resource "vault_pki_secret_backend_role" "pki-server" {
  backend            = vault_mount.pki_sica_v2.path
  name               = "pki-server"
  ttl                = local.default_72h_in_sec
  max_ttl            = local.default_1y_in_sec
  allow_localhost    = false
  allow_ip_sans      = false
  allow_subdomains   = true
  server_flag        = true
  client_flag        = false
  allow_glob_domains = false
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  allowed_domains    = var.allowed_domains
  country            = [var.country]
  locality           = [var.locality]
  province           = [var.province]
  organization       = [var.organization]
}

## Server certs limited to allowed_domains
resource "vault_pki_secret_backend_role" "spire_x509pop" {
  backend            = vault_mount.pki_sica_v2.path
  name               = "spire-x509pop"
  ttl                = local.default_72h_in_sec
  max_ttl            = local.default_1y_in_sec
  allow_localhost    = false
  allow_ip_sans      = false
  allow_wildcard_certificates = false
  allow_subdomains   = true
  server_flag        = false
  client_flag        = true
  key_usage          = ["DigitalSignature", "KeyEncipherment"]
  ext_key_usage      = ["ClientAuth"]
  allowed_domains    = var.allowed_domains
  country            = [var.country]
  locality           = [var.locality]
  province           = [var.province]
  organization       = [var.organization]
}
