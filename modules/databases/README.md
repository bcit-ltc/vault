# PostgreSQL Dynamic Secrets

- Reads `postgresql_databases` from the root `terraform.tfvars` and loops apps to create one connection+role per app.
- Mount path defaults to `postgres`.

Usage:

    terraform init
    terraform apply

Notes:

- DB name derives from app by replacing '-' with '_' (e.g., qcon-api -> qcon_api).
- Each app produces a Vault connection `pg-core-<app>` and role `<app>_rw`.
