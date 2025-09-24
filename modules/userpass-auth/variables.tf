variable "userpass_accessor" {
  description = "Mount accessor for the userpass auth method (e.g., auth_userpass_abcd1234)"
  type        = string
}

variable "userpass_mount" {
  description = "Mount path for the userpass auth method"
  type        = string
  default     = "userpass"
}
