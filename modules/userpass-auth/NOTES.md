# Userpass

## Command to create new userpass entity

```bash
export VAULT_ADDR="{yourVaultAddress}"
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data '{"token_ttl":"8h","token_max_ttl":"12h"}' \
    $VAULT_ADDR/v1/auth/userpass/users/ltc-admin
```

1. Create user

```bash
vault write auth/userpass/users/${VAULT_USER} \
password=${VAULT_PASSWORD} \
token_policies="pki-issue-certs" \
token_no_default_policy=true \
token_ttl="1h" \
token_max_ttl="24h" \
bound_cidrs="10.10.0.0/16""
```
