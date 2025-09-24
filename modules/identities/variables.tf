variable "identities_yaml_path" {
    description = "Path to identities.yaml (relative to path.root)."
    type = string
}
variable "oidc_auth_accessor" {
    description = "Accessor of the OIDC auth mount (from the vault-oidc module output)."
    type = string
}
