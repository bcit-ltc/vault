variable "apps" {
  description = "List of app names (used to derive per-app policies/roles)"
  type        = list(string)
  default     = []
}

variable "apps_grouped" {
  description = "Parent namespace => list of child apps. Children bind to the parent namespace."
  type        = map(list(string))
  default     = {}
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

  validation {
    condition     = var.token_ttl_seconds > 0
    error_message = "token_ttl_seconds must be a positive number."
  }
}

variable "clusters" {
  description = "Map of cluster name -> { host, current_env }"
  type = map(object({
    host        = string
    current_env = string
  }))

  validation {
    condition     = length(var.clusters) > 0
    error_message = "clusters must not be empty."
  }

  validation {
    condition = alltrue([
      for c in values(var.clusters) :
      can(regex("^https?://", c.host)) && length(trimspace(c.current_env)) > 0
    ])
    error_message = "Each cluster.host must start with http(s):// and current_env must not be empty."
  }
}

variable "k8s_auth_path_prefix" {
  description = "Base Vault path for Kubernetes cluster auth materials (no trailing slash)"
  type        = string

  validation {
    condition     = !can(regex("/data/", var.k8s_auth_path_prefix))
    error_message = "k8s_auth_path_prefix must NOT include '/data/'. Use the logical mount path only (KV v2 provider rewrites internally)."
  }
}

variable "acl_policy_mount" {
  description = "KV mount name for app ACL policies (KV v2 logical path, no /data/)"
  type        = string
  default     = "apps"
}

variable "private_apps" {
  description = "Apps that should receive the GitHub private tokens policy across all envs."
  type        = list(string)
  default     = []
}

variable "github_private_tokens_policy" {
  description = "Policy name to add to selected apps."
  type        = string
  default     = "read-ltc-infrastructure-github-gh-private-oci-token"
}
