# Encrypt secrets using transit engine

## SOPS

1. Temporarily store the secret on-disk

```bash
cat signing.key
```

1. Login to Vault & confirm transit engine access

```bash
vault login -method=x && vault token lookup
```

1. Encrypt the secret using the `--hc-vault-transit` configuration

```bash
sops -e --hc-vault-transit https://${VAULT_ADDR}/v1/sops/keys/gitops-key signing.key > signing.key.encrypted
```

1. Confirm decryption works

```bash
sops -d signing.key.encrypted
```

1. Remove the secret

```bash
rm signing.key
```

### Optional: setup a `.sops.yaml` file

Configuring this file will tell sops to automatically decrypt certain fields of certain types of files. For example:

```bash
creation_rules:
  - path_regex: ".*\\.yaml"
    encrypted_regex: ^(data|stringData)$
    hc_vault_transit_uri: "https://${VAULT_ADDR}/v1/sops/keys/gitops-key"
  - hc_vault_transit_uri: "https://${VAULT_ADDR}/v1/transit/keys/primary-signing-key"
```

This config file tells sops to look for all `.yaml` files and to only encrypt/decrypt portions of the file that begin with `data` or `stringData` with the `gitops-key`. This is useful to allow humans to read the file contents *except* for the encrypted portions. For all other file types, files should be encrypted/decrypted with the `primary-signing-key`.
