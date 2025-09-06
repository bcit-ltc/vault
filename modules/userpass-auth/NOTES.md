# Userpass

## Command to create new userpass entity

```bash
export VAULT_ADDR="https://vault.ltc.bcit.ca:8200"
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"token_ttl":"8h","token_max_ttl":"12h"}' \
    $VAULT_ADDR/v1/auth/userpass/users/ltc-admin
```

## Create the user "pki-ltc-cert-issuer"

> not codified in Terraform because p/w is visible in lock file...

1. export variables

> **Actual credentials are stored at path `/ltc-infrastructure/pki-ltc-cert-issuer`**

```bash
export VAULT_USER="pki-ltc-cert-issuer" && \
export VAULT_PASSWORD="superSecretPassword2"
```

1. Create user

```bash
vault write auth/userpass/users/${VAULT_USER} \
password=${VAULT_PASSWORD} \
token_policies="pki-ltc-issue-certs" \
token_no_default_policy=true \
token_ttl="1h" \
token_max_ttl="24h" \
bound_cidrs="10.12.0.0/16", "10.42.0.0/16", "10.67.0.0/16", "142.232.0.0/16", "192.68.68.0/24"
```
