# Manage the Vault DB secrets engine mount here
variable "manage_mount" {
    type = bool
    default = true
}
variable "db_mount_path" {
    type = string
    default = "postgres"
}
variable "pg_host" {
    type = string
}
variable "pg_port" {
    type = number
}
variable "admin_username" {
    type = string
}
variable "admin_password" {
    type = string
    sensitive = true
}
variable "postgresql_databases" {
    type = list(string)
}
variable "envs" {
  description = "Environments to suffix policy names with (e.g., [\"stable\"])"
  type        = list(string)
  default     = ["stable"]
}
