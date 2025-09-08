# OIDC auth
# https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread

# Retrieve Azure (Entra ID) app credentials
data "vault_generic_secret" "oidc_credentials" {
  path = var.oidc_secret_path
}

# Auth backend (mount)
resource "vault_jwt_auth_backend" "oidc" {
  path               = "oidc"
  type               = "oidc"
  description        = "Authenticate to BCIT (AzureAD)"

  oidc_discovery_url = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
  oidc_client_id     = data.vault_generic_secret.oidc_credentials.data["client_id"]
  oidc_client_secret = data.vault_generic_secret.oidc_credentials.data["client_secret"]

  default_role = "default-oidc-role"

  tune {
    listing_visibility = "unauth"
  }

  lifecycle {

    # Prevents noisy plans caused by server-populated defaults in tune
    ignore_changes = [tune]
  }

  provider_config = {
    provider = "azure"
    # fetch_groups = true            # if we rely on MS Graph group expansion...tbd
    # fetch_user_info = true
    # groups_recurse_max_depth = 1
  }
}

# Lookup mount to fetch the accesssor (for group alias)
# Using the mount path reference avoids race conditions.
data "vault_auth_backend" "this" {
  path = vault_jwt_auth_backend.oidc.path
}

# Identity Group + Alias
resource "vault_identity_group" "aad_users" {
  name     = "aad-${replace(var.aad_group.name, " ", "-")}"
  type     = "external"
  policies = var.aad_group_policies
  metadata = {
    source_group_name = var.aad_group.name
    source_object_id  = var.aad_group.object_id
  }
}

resource "vault_identity_group_alias" "aad_users_alias" {
  name           = var.aad_group.object_id            # value emitted in AAD 'groups' claim
  mount_accessor = data.vault_auth_backend.this.accessor
  canonical_id   = vault_identity_group.aad_users.id

  lifecycle {

    # Accessor is computed by Vault and shows as "known after apply" in plans.
    # Ignore post-create drift so 'plan' doesn't propose in-place updates forever.
    ignore_changes = [mount_accessor]
  }
}
