output "oidc_auth_accessor" {
  description = "Accessor of the Vault OIDC/JWT auth mount"
  value       = data.vault_auth_backend.oidc.accessor
}

output "idp_client_ids" {
  description = "Map of client name -> OIDC client_id"
  value       = {
    for k, c in vault_identity_oidc_client.client :
    k => c.client_id
  }
}

output "idp_issuer_urls" {
  description = "Useful endpoints for the Vault Identity OIDC provider (issuer)"
  value = {
    issuer                   = "https://${var.issuer_host}/v1/identity/oidc/provider/${var.provider_name}"
    openid_configuration_url = "https://${var.issuer_host}/v1/identity/oidc/provider/${var.provider_name}/.well-known/openid-configuration"
    auth_endpoint            = "https://${var.issuer_host}/v1/identity/oidc/provider/${var.provider_name}/authorize"
    jwks_uri                 = "https://${var.issuer_host}/v1/identity/oidc/provider/${var.provider_name}/.well-known/keys"
    token_endpoint           = "https://${var.issuer_host}/v1/identity/oidc/provider/${var.provider_name}/token"
    user_info_endpoint       = "https://${var.issuer_host}/v1/identity/oidc/provider/${var.provider_name}/token"
  }
}
