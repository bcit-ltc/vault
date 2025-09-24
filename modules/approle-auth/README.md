# approle-auth

A minimal AppRole auth module.

## Inputs

- `auth_path` (string, default `"approle"`): mount path for the AppRole backend.
- `token_ttl_seconds` (number, default `3600`), `token_max_ttl_seconds` (number, default `86400`)
- `token_bound_cidrs` (list(string), default `[]`)

## Outputs

- `role_ids` (map(role_name => RoleID)) — SecretIDs are not exposed.

## Example call

```hcl
module "approle_auth" {
  source = "./modules/approle-auth"

  token_bound_cidrs     = ["10.10.0.0/16"]

  role = {
    token_policies        = ["default","read-app"]
    token_ttl_seconds     = 900
    token_bound_cidrs     = ["192.168.1.1/24"]
    token_no_default_policy = true
  }

}

output "approle_backend" { value = module.aprole_auth.backend_path }
output "approle_role_ids" { value = module.aprole_auth.role_ids }
```
