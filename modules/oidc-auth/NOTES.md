# OIDC auth method

- NOTE: OIDC auth method is only configured after registering and configuring an EntraID app in Azure*

## Requirements

This module looks for `client_id` and `client_secret` values that correspond to a pre-configured EntraID app.

Secrets are expected to be at `mount=ltc-infrastructure` `path=vault/oidc-auth-credentials`.
