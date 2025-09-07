<!-- SPDX-License-Identifier: MPL-2.0 -->

# HashiCorp Vault configured with Terraform

This project deploys HashiCorp Vault resources and stores the state remotely in Azure Blob Storage.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with permissions to create resources
- Azure CLI
- Vault CLI
- Kubernetes CLI (for `modules/kubernetes-auth`)

## Getting Started

1. Clone this repo and install the requirements.

    > [!IMPORTANT]
    > Modules should be applied incrementally.
    > Start by commenting-out the following special modules in `main.tf`:
    >
    > - Mod 2: Identity and access management
    > - Mod 3: Kubernetes mounts, backend config, and roles
    > - Mod 4: AzureAD auth
    >
    > These modules have special requirements, and can be applied after an initial `terraform plan` and the required init secrets are loaded.

    > [!NOTE]
    > It is recommended to comment out the entire terraform block in `main.tf` until a local state is established.
    >
    > When an appropriate backend is configured, state can be migrated with:
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

1. Enable the `secrets` engine

    ```bash
    terraform apply -target=module.secrets.vault_mount.kv_mount -auto-approve
    ```

1. Enable `modules/kubernetes-auth`

    1. Load required secrets

        - cluster CA certificate
        - service account token

            *See [modules/kubernetes-auth/NOTES.md](modules/kubernetes-auth/NOTES.md) for details.*

    1. Uncomment the module in `main.tf`
    1. Plan and apply the config

1. Enable `/modules/oidc-auth`

    1. Load required secrets

        - client_id
        - client_secret

            *See [modules/oidc-auth/NOTES.md](./modules/oidc-auth/NOTES.md) for details.*

    1. Uncomment the module in `main.tf`
    1. Plan and apply the config

## License

Copyright (c) 2008-2025 [BCIT LTC](https://www.bcit.ca/learning-teaching-centre/)

This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. If a copy of the MPL was not distributed with this file, You can obtain one at <https://mozilla.org/MPL/2.0/>.

## About

Developed in 🇨🇦 Canada by [BCIT's](https://www.bcit.ca/) [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/). [Contact Us](mailto:ltc_techops@bcit.ca).
