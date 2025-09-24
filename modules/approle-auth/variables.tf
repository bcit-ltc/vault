# Roles with overridable names and policies.
variable "approle_roles" {
  description = <<-EOT
  Map of role_name -> settings. Creates one AppRole per entry.
  Keys are role names; values set policies and (optionally) per-role TTL/CIDRs.
  EOT
  type = map(object({
    token_policies          = list(string)
    token_ttl_seconds       = optional(number)        # falls back to module default
    token_max_ttl_seconds   = optional(number)        # falls back to module default
    token_bound_cidrs       = optional(list(string))  # falls back to module default
    token_no_default_policy = optional(bool, true)
  }))
}

variable "auth_path" {
  type = string
  default = "approle"
}

variable "token_ttl_seconds" {
  type = number
  default = 3600
}

variable "token_max_ttl_seconds" {
  type = number
  default = 86400
}

variable "token_bound_cidrs" {
  type = list(string)
  default = []
}

variable "approle_secretid_roles" {
  description = "Roles for which SecretID creation is permitted"
  type        = list(string)
  default     = []
}
