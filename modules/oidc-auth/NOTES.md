# OIDC auth method

- NOTE: OIDC auth method is only configured after adding an EntraID app in Azure*

## Required secrets

This module looks for `client_id` and `client_secret` values that correspond to a pre-configured EntraID app.

Secrets are expected to be at `/v1/ltc-infrastructure/data/vault/oidc-auth-credentials`.
