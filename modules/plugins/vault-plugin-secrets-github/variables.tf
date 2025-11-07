variable "vault_github_secrets_plugin_app_credentials" {
  description = "Path to the Vault generic secret that stores plugin and app credentials"
  type        = string
}

variable "base_url" {
  description = "GitHub API base URL (defaults to https://api.github.com)"
  type        = string
  default     = "https://api.github.com"
}

variable "exclude_repository_metadata" {
  description = "Whether to exclude repository metadata for token creation"
  type        = bool
  default     = true
}

variable "mount_path" {
  description = "Mount path for the GitHub secrets engine"
  type        = string
  default     = "github"
}

variable "policy_name" {
  description = "Name of the Vault policy for token creation"
  type        = string
  default     = "write-github-private-tokens"
}
