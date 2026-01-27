# OIDC auth notes

- [Vault OIDC Provider Documentation](https://developer.hashicorp.com/vault/docs/concepts/oidc-provider)
- [Rancher Generic OIDC configuration](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/authentication-permissions-and-global-configuration/authentication-config/configure-generic-oidc)

Run `curl -s https://${VAULT_ADDR}/v1/identity/oidc/provider/vault-provider/.well-known/openid-configuration | jq` to retrieve correct endpoints.

Add additional OIDC Provider clients to the project root `terraform.tfvars` with the format:

```bash
oidc_clients = {
  rancher = {
    redirect_uris        = [
      "https://{rancherOidcClientUrl}/verify-auth",
      "https://{rancherOidcClientUrl}/callback"
    ]
    # assignment_group_ids  = [ module.vault_identities.group_ids_internal["course-production"] ] # wire from identities if desired
    allow_all     = true
  }
```

Running `terraform apply` will generate an output with the `client_id` but the `client_secret` must be retrieved manually:

```bash
vault read identity/oidc/client/rancher
```
