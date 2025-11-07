variable "identities_yaml" {
  description = "Raw YAML for identities. Caller passes file(...). Must contain groups.internal.*"
  type        = string
}
variable "mount" {
  description = "KV v2 mount name for team secrets."
  type        = string
  default     = "private-team"
}
