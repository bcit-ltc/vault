# Create ephemeral, finely-scoped @github access tokens using @hashicorp Vault. 
# https://github.com/martinbaillie/vault-plugin-secrets-github

# Requirements:
# 1. Vault plugin directory configured in vault.hcl
# 2. Compiled binary exists in Vault's plugin directory (e.g. /opt/vault/plugins)
# 3. Binary SHA256SUM matches the local file
# 4. GitHub App configured (app_id, private_key, and installation_id)

# Pull config from Vault:
#   mount = ltc-infrastructure
#   name  = github/vault-github-secrets-plugin-app-credentials
data "vault_generic_secret" "github_app" {
  path = var.vault_github_secrets_plugin_app_credentials
}

resource "vault_plugin" "github" {
  name    = "vault-plugin-secrets-github"
  type    = "secret"
  sha256  = data.vault_generic_secret.github_app.data["plugin_sha256"]
  command = data.vault_generic_secret.github_app.data["plugin_command"]
  version = data.vault_generic_secret.github_app.data["plugin_version"]
}

resource "vault_generic_endpoint" "github_mount" {
  path                 = "sys/mounts/${var.mount_path}"
  disable_read         = true
  ignore_absent_fields = true

  data_json = jsonencode({
    type           = "plugin"
    plugin_name    = "vault-plugin-secrets-github"
    description    = "GitHub token secrets engine (GitHub App)"
    plugin_version = data.vault_generic_secret.github_app.data["plugin_version"]
  })

  # ensure the catalog entry exists before we try to mount a specific version
  depends_on = [vault_plugin.github]
}

resource "vault_generic_endpoint" "github_config" {
  path                 = "${var.mount_path}/config"
  disable_read         = true
  ignore_absent_fields = true

  data_json = jsonencode({
    app_id                      = data.vault_generic_secret.github_app.data["app_id"]
    base_url                    = var.base_url
    exclude_repository_metadata = var.exclude_repository_metadata
    prv_key                     = data.vault_generic_secret.github_app.data["private_key"]
  })

  depends_on = [vault_generic_endpoint.github_mount]
}

data "vault_policy_document" "github_token" {
  rule {
    path         = "${var.mount_path}/token"
    capabilities = ["read","create","update"]
  }
}

resource "vault_policy" "write_github_private_tokens" {
  name   = "write-github-private-tokens"
  policy = data.vault_policy_document.github_token.hcl
}

# Admin policy for plugin
resource "vault_policy" "admin_github_private_tokens" {
  name   = "admin-github-private-tokens"
  policy = <<EOT
# Manage GitHub token secrets
path "${var.mount_path}"    { capabilities = ["read"] }
path "${var.mount_path}/*"  { capabilities = ["create","read","update","delete"] }
EOT
}
