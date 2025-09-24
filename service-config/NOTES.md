# Vault Service Info

This path stores the Vault service config as a reference - it should match `/etc/vault.d/vault.hcl` on the server with TLS and AWS KMS secret values filled-in. See the `/etc/vault.d/vault.env` file for values.

## Service Information

### Remote State

Remote state is stored in Azure Blob Storage. Ensure the storage account, container, and resource group exist before running `terraform init`.

### Unseal curl

```bash
export VAULT_ADDR="${yourVaultAddress}"
curl \
    --request POST \
    --data '{"key": "abcd1234..."}' \
    $VAULT_ADDR/v1/sys/unseal
```
