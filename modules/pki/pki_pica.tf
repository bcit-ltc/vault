# Mount point for the Primary Intermediate CA (PICA).
resource "vault_mount" "pki_pica" {
  path                      = "pki/pica"
  type                      = "pki"
  description               = "${var.short_org} ${var.ou} PKI Primary Intermediate CA"
  default_lease_ttl_seconds = local.default_1y_in_sec
  max_lease_ttl_seconds     = local.default_3y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_pica" {
  depends_on   = [vault_mount.pki_pica]
  backend      = vault_mount.pki_pica.path
  type         = "internal"
  common_name  = "${var.short_org} ${var.ou} PKI Primary Intermediate CA v2"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = var.ou
  organization = var.organization
  country      = var.country
  locality     = var.locality
  province     = var.province
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_pica_signed_cert" {
  depends_on  = [vault_mount.pki_pica]
  backend     = vault_mount.pki_pica.path
  certificate = file(var.primary_ca_cert_path)
}
