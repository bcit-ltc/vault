variable "tenant_id" {
  type    = string
  default = "8322cefd-0a4c-4e2c-bde5-b17933e7b00f"
}

# The client creds live in Vault; path is configurable
variable "oidc_secret_path" {
  type    = string
  default = "ltc-infrastructure/vault/oidc-auth-credentials"
}

# OIDC app can return to these (UI, CLI callback, etc.)
variable "redirect_uris" {
  type = list(string)
  default = [
    "https://vault.ltc.bcit.ca:8200/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"     # required for CLI
  ]
}

# Policies for the AAD group
variable "aad_group_policies" {
  type    = list(string)
  default = [
    "default", 
    "read-ltc-infrastructure-inventory", 
    "use-transit-gitops-key", 
    "read-external"
  ]
}

# AAD group info (Entra emits in the token's `groups` claim)
variable "aad_group" {
  type = object({
    name       : string
    object_id  : string
  })
  default = {
    name      = "AAD_SSO_VaultLTC_Users_Adhoc"
    object_id = "ba556f91-1b8c-41f5-af12-8e5e75b05d6b"
  }
}
