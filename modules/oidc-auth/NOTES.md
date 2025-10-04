# OIDC auth notes

Add additional OIDC Provider clients to the project root `terraform.tfvars` with the format:

```bash
oidc_clients = {
  rancher = {
    redirect_uris        = [
      "https://rancher3.ltc.bcit.ca/verify-auth",
      "https://rancher3.ltc.bcit.ca/callback"
    ]
    # assignment_group_ids  = [ module.vault_identities.group_ids_internal["course-production"] ] # wire from identities if desired
    allow_all     = true
  }
```

Running `terraform apply` will generate an output with the `client_id` but the `client_secret` must be retrieved manually:

```bash
vault read identity/oidc/client/rancher
```
