variable "tenant_id" { 
  description = "Azure Entra ID tenant (GUID)"
  type = string 
}

variable "oidc_auth_path" { 
  description = "Mount path for Vault JWT/OIDC auth backend"
  type = string
  default = "oidc"
}

variable "oidc_client_id" { 
  description = "Entra application (client) ID"
  type = string 
}

variable "oidc_client_secret" { 
  description = "Entra application client secret"
  type = string
  sensitive = true
}

variable "allowed_redirect_uris" { 
  description = "Allowed redirect URIs for the *login* OIDC role (Vault UI/CLI callbacks)"
  type = list(string) 
}

variable "provider_name" { 
  description = "Name for the Vault Identity OIDC provider (Vault-as-IdP)"
  type = string
  default = "vault-provider"
}

variable "issuer_host" { 
  description = "Public host[:port] Vault will advertise for its OIDC provider (no scheme)"
  type = string
}

variable "clients" {
  description = <<-EOT
  Map of OIDC clients to create under this provider.
  Key = client name; value:
    - redirect_uris           : list(string), required
    - assignment_entity_ids   : list(string), optional (default [])
    - assignment_group_ids    : list(string), optional (default [])
    - allow_all               : bool,         optional (default false)
    - id_token_ttl            : number,       optional (default 2400)
    - access_token_ttl        : number,       optional (default 7200)
  EOT
  type = map(object({
    redirect_uris         = list(string)
    assignment_entity_ids = optional(list(string), [])
    assignment_group_ids  = optional(list(string), [])
    allow_all             = optional(bool, false)
    id_token_ttl          = optional(number, 2400)
    access_token_ttl      = optional(number, 7200)
  }))
}
