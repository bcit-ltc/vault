# Prefix for per-env mounts: <prefix>-<env>
variable "db_mount_prefix" {
  type        = string
  default     = "postgresql"
}

# Environments (e.g., ["latest","stable"])
variable "envs" {
  type = list(string)
}

# App identifiers (used for schema & group names; "-" normalized to "_")
variable "postgresql_databases" {
  type = list(string)
}

# Strict per-env connection map (no fallback)
variable "pg_connections" {
  type = map(object({
    host = string
    port = number
  }))
}

variable "admin_passwords" {
  description = "Per-environment Postgres admin passwords, keyed by environment (e.g. stable, latest)."
  type        = map(string)
  sensitive   = true
}


# Fixed DB & plugin settings (kept as vars in case they ever need to change)
variable "admin_database" {
  type    = string
  default = "postgres"
}

variable "plugin_name" {
  type    = string
  default = "postgresql-database-plugin"
}

variable "connection_name" {
  description = "Prefix for connection objects; actual names are <prefix>-<env>"
  type        = string
  default     = "pg-core"
}

variable "app_role_suffix" {
  description = "Suffix for per-app group roles (e.g., <app>_app)"
  type        = string
  default     = "_app"
}

variable "default_ttl_seconds" {
  type    = number
  default = 86400       # 1 day
}

variable "max_ttl_seconds" {
  type    = number
  default = 2592000     # 30 days
}

# Manager role defaults (always created; no toggle)
variable "manager_role_name" {
  type    = string
  default = "db_root_owner"
}

variable "manager_token_period" {
  type    = number
  default = 86400
}
