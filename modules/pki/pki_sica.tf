# Mount point for the Secondary Intermediate CA (SICA).
resource "vault_mount" "pki_sica_v2" {
  path                      = "pki/sica/v2"
  type                      = "pki"
  description               = "${var.short_org} ${var.ou} PKI Secondary Intermediate CA v2"
  default_lease_ttl_seconds = local.default_1d_in_sec
  max_lease_ttl_seconds     = local.default_1y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_sica_v2" {
  depends_on   = [vault_mount.pki_sica_v2]
  backend      = vault_mount.pki_sica_v2.path
  type         = "internal"
  common_name  = "${var.short_org} ${var.ou} PKI Secondary Intermediate CA v2"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = var.ou
  organization = var.organization
  country      = var.country
  locality     = var.locality
  province     = var.province
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_sica_v2_sign_by_pki_pica" {
  depends_on = [
    vault_mount.pki_pica,
    vault_pki_secret_backend_intermediate_cert_request.pki_sica_v2
  ]
  backend              = vault_mount.pki_pica.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.pki_sica_v2.csr
  common_name          = "${var.short_org} ${var.ou} PKI Secondary Intermediate CA v2"
  exclude_cn_from_sans = true
  ou                   = var.ou
  organization         = var.organization
  country              = var.country
  locality             = var.locality
  province             = var.province
  max_path_length      = 1
  ttl                  = local.default_1y_in_sec
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_sica_v2_signed_cert" {
  depends_on  = [vault_pki_secret_backend_root_sign_intermediate.pki_sica_v2_sign_by_pki_pica]
  backend     = vault_mount.pki_sica_v2.path
  certificate = format("%s\n%s", vault_pki_secret_backend_root_sign_intermediate.pki_sica_v2_sign_by_pki_pica.certificate, file(var.primary_ca_cert_path))
}

resource "vault_pki_secret_backend_config_auto_tidy" "pki_sica_v2_auto_tidy" {
  backend     = vault_mount.pki_sica_v2.path
  enabled = true
  tidy_cert_store = true
  interval_duration = "36h"
}
