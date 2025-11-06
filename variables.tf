variable "vault_addr" {
  description = "Vault server address (e.g., https://vault.example.com:8200)"
  type        = string
}

variable "vault_token" {
  description = "Admin token for provisioning"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Entra ID tenant (GUID)"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
  default     = "terraform"
}

variable "location" {
  description = "Azure region for the Resource Group and Storage Account."
  type        = string
  default     = "canadacentral"
}

variable "container_name" {
  description = "Blob container name (lowercase letters, numbers, and hyphens)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$", var.container_name))
    error_message = "container_name must be 3–63 chars, lowercase letters, numbers, hyphens; start/end alphanumeric."
  }
  default     = "tfstate"
}

variable "oidc_credentials_path" {
  description = "Path to the OIDC credentials in Vault"
  type        = string
}
variable "allowed_redirect_uris" {
  description = "List of allowed redirect URIs for OIDC"
  type        = list(string)
}

variable "issuer_host" {
  description = "Issuer host for OIDC"
  type        = string
}

variable "oidc_clients" {
  description = "Map of OIDC clients"
  type = map(object({
    redirect_uris        = list(string)
    assignment_group_ids = optional(list(string), [])
    allow_all            = optional(bool, false)
  }))
  validation {
    condition = alltrue([
      for c in values(var.oidc_clients) :
      (c.allow_all == true) || (length(c.assignment_group_ids) > 0)
    ])
    error_message = "Each client must set allow_all = true or provide non-empty assignment_group_ids."
  }
  default = {}
}

variable "clusters" {
  description = "Kubernetes clusters keyed by name. current_env is unique per cluster; workload_connection is the hostname/IP used for DB connections."
  type = map(object({
    host                 = string
    workload_connection  = string
    current_env          = string
  }))
}

variable "pg_port" {
  description = "PostgreSQL NodePort used by Vault to reach each env's CNPG cluster."
  type        = number
}

variable "postgresql_admin_username" {
  type = string
}

variable "postgresql_admin_password" {
  type      = string
  sensitive = true
}

variable "postgresql_databases" {
  description = "List of app identifiers; one role per app per env"
  type        = list(string)
}

variable "apps" {
  description = "List of app names to create k8s auth roles for"
  type        = list(string)
}

variable "apps_grouped" {
  type        = map(list(string))
  default     = {}
  description = "List of apps grouped into one namespace for k8s auth roles"
}

variable "common_policies" {
  description = "Policies granted to all clusters"
  type        = list(string)
  default     = []
}

variable "token_bound_cidrs" {
  description = "CIDRs to bind service account tokens for Kubernetes auth roles"
  type        = list(string)
  default     = []
}

variable "token_ttl_seconds" {
  description = "Default token TTL for Kubernetes roles"
  type        = number
  default     = 14400
}

variable "k8s_auth_path_prefix" {
  description = "Base Vault path for Kubernetes cluster auth materials"
  type        = string
}

variable "private_legacy_apps" {
  description = "Apps that should receive the GitHub private tokens policy."
  type        = list(string)
  default     = []
}

variable "github_private_tokens_policy" {
  description = "Policy name for GitHub private tokens access."
  type        = string
  default     = "read-ltc-infrastructure-github-private-tokens"
}
