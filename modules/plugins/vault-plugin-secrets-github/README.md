# Vault plugin for GitHub tokens

Create ephemeral, finely-scoped @github access tokens using @hashicorp Vault. [https://github.com/martinbaillie/vault-plugin-secrets-github](https://github.com/martinbaillie/vault-plugin-secrets-github)

## Requirements

1. Vault plugin directory configured in vault.hcl
2. Compiled binary exists in Vault's plugin directory (e.g. /opt/vault/plugins)
3. Binary SHA256SUM matches the local file
4. GitHub App configured (app_id, private_key, and installation_id)

## Usage

Create a token for temporary use:

```bash
vault read github/token org_name="bcit-ltc"
```

Revoke the token lease

```bash
vault lease revoke github/token/{tokenLeaseID}
```

## Configuration

```bash
vault read github/config
```
