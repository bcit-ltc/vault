<!-- markdownlint-disable MD028 -->

# HashiCorp Vault configured with Terraform

This project uses Terraform to deploy Vault resources; backend state is stored remotely in Azure blob storage.

## Prerequisites

- Terraform >= 1.0
- Vault CLI
- Azure CLI for state storgage

### Optional

- if using OIDC auth, Azure Entra ID app pre-configuration required
- if using Kubernetes auth, Kubernetes CLI and cluster required

## Getting Started

> [!IMPORTANT]
> Modules should be applied incrementally because some modules retrieve values from Vault.
> Start by applying the KV secrets engine module, loading the required secrets, and then applying the remaining modules.

> [!NOTE]
> Comment out the entire terraform block in `main.tf` until a local state is established.
>
> When a backend is configured, state can be migrated with:
>
> ```bash
> terraform init -migrate-state
> ```

1. Login to Vault

    ```bash
    vault login {initialRootToken}
    ```

1. Initialize Terraform

    ```bash
    terraform init
    ```

1. Apply the KV secrets engine

```bash
terraform apply -target=module.secrets.vault_mount.kv_mount -auto-approve
```

1. Load the required secrets

- `oidc_credentials_path` -> seeks Entra ID app `client_id` and `client_secret`
- kubernetes_auth `ca_pem` and `token_reviewer_jwt`

## Applying Special Modules

Start by enabling the `secrets` engine

```bash
terraform plan
terraform apply
```

### Identity module

This module sets up groups and entities based on the configuration in the root `identities.yaml` file.

### Kubernetes auth

> See [modules/kubernetes-auth/NOTES.md](modules/kubernetes-auth/NOTES.md).

This module configures Kubernetes access to Vault. See `terraform.tfvars.example` for how to use.

1. Load the required secrets into the KV engine at (`${k8s_auth_path_prefix}/clusters/${cluster0X}`)

    Required secrets:

    - cluster CA certificate (`ca_pem`)
    - service account token (`token_reviewer_jwt`)

    Secret structure:

    ```json
    {
        "ca_pem": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----",
        "token_reviewer_jwt": "xxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyy.zzzzzzzzzzzzzzz"
    }
    ```

1. Uncomment the module in `main.tf`
1. `plan` and `apply` the config

### OIDC auth

> See [modules/oidc-auth/NOTES.md](./modules/oidc-auth/NOTES.md) for details.

1. Load the required secrets into the KV engine at (`oidc_credentials_path`)

    - client_id
    - client_secret

    Secret structure:

    ```json
    {
    "client_id": "{yourAzureAppClientID}",
    "client_secret": "{yourAzureAppClientSecret}"
    }
    ```

1. Uncomment the module in `main.tf`
1. `plan` and `apply` the config

## About

Developed in 🇨🇦 Canada by the [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/) at [BCIT](https://www.bcit.ca/).
