# Vault Service Info

This path stores the Vault service config as a reference - it should match `/etc/vault.d/vault.hcl` on the server.

## Service Information

### Remote State

Remote state is stored in Azure Blob Storage. Ensure the storage account, container, and resource group exist before running `terraform init`.

### Unseal curl

```bash
export VAULT_ADDR="https://vault.ltc.bcit.ca:8200"
curl \
    --request POST \
    --data '{"key": "abcd1234..."}' \
    $VAULT_ADDR/v1/sys/unseal
```
