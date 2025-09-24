<!-- markdownlint-disable MD046 -->
# About Secrets

Secrets are PUT into Vault using the CLI or the Web UI - rather than by Terraform - so that they do not persist in state files in plain text.

Use a token with appropriate authorization to put a secret.

**Using the vault cli:**

```bash
vault kv put apps/web-apps/qcon-api \
name="dependabot-qcon-api" \
password="someSecretPa$$w0rd"
```

**API call using cURL:**

```bash
echo "{"username":"foo","password":"bar"} > payload.json

curl --header "X-Vault-Token: $VAULT_TOKEN" \
--request POST \
--data @payload.json \
$VAULT_ADDR/v1/secret/data/customer/acme | jq
```

## Secrets path structure

### `/apps`

Secrets should match the following:

    apps/{service}/{environment}/{secret-name}

For example:

    apps/scheduler-web/latest/local-credentials
    apps/qcon-api/stable/django-secrets

### `/ltc-infrastructure`

Secrets in the `ltc-infrastructure` engine follow the schema:

    ltc-infrastructure/{service}

For example:

    ltc-infrastructure/ansible
    ltc-infrastructure/clusters/cluster03

### Notes

* `private-*` engines are mapped through policy templates to be only accessible to teams; only the root token can access secrets at these paths.
