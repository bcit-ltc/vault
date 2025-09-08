<!-- SPDX-License-Identifier: MPL-2.0 -->
<!-- markdownlint-disable MD028 -->

# HashiCorp Vault configured with Terraform

This project uses Terraform to deploy Vault resources; backend state is stored remotely in Azure blob storage.

## Prerequisites

- Terraform >= 1.0
- Vault CLI
- Azure CLI for state storgage

### Optional

- if using OIDC auth, Azure app pre-configuration required
- if using Kubernetes auth, Kubernetes CLI and cluster required

## Getting Started

> [!IMPORTANT]
> Modules should be applied incrementally.
> Start by commenting-out the following modules in `main.tf`:
>
> - Mod 2: Identity and access management
> - Mod 3: Kubernetes mounts, backend config, and roles
> - Mod 4: AzureAD auth
>
> These modules have special requirements, and can be applied after an initial `terraform plan` and the required init secrets are loaded.

> [!NOTE]
> It is recommended to comment out the entire terraform block in `main.tf` until a local state is established.
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

1. Apply the Vault configurations

```bash
terraform plan
terraform apply
```

## Applying Special Modules

Start by enabling the `secrets` engine

```bash
terraform apply -target=module.secrets.vault_mount.kv_mount -auto-approve
```

### Identity module

This module sets up groups and entities based on the configuration in the module's `identities.yaml` file.

### Kubernetes auth

> See [modules/kubernetes-auth/NOTES.md](modules/kubernetes-auth/NOTES.md).

This module configures Kubernetes access to Vault based on the configuration in `clusters.yaml`.

1. Load the required secrets

    - cluster CA certificate
    - service account token

1. Uncomment the module in `main.tf`
1. Plan and apply the config

### OIDC auth

> See [modules/oidc-auth/NOTES.md](./modules/oidc-auth/NOTES.md) for details.

1. Load the required secrets

    - client_id
    - client_secret

1. Uncomment the module in `main.tf`
1. Plan and apply the config

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. If a copy of the MPL was not distributed with this file, You can obtain one at <https://mozilla.org/MPL/2.0/>.

## About

Developed in 🇨🇦 Canada by the [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/) at [BCIT](https://www.bcit.ca/).
