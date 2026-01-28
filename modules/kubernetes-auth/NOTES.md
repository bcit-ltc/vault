<!-- markdownlint-disable code-block-style -->

# Configure kubernetes auth

> <https://developer.hashicorp.com/validated-patterns/vault/vault-kubernetes-auth>

A service account token is required to authenticate with the kubernetes auth backend. The `vault-tokenauth` service account is created by the flux bootstrap init process (see the `flux` repo `init/README.md`), and after the ServiceAccount is created, these steps retrieve the credential and configure this auth method.

## Requirements

- Vault CLI
- Kubernetes CLI and cluster access
- Terraform
- Azure CLI and storage blob access (state file)
- jq

## Setup

1. Login to Vault

    ```bash
    vault login -method=oidc username={yourUsername}    # enter password interactively
    ```

1. Set the cluster context

    ```bash
    export CLUSTER=cluster0X        # make sure your context matches your intended environment

    kubectl config use-context ${CLUSTER}
    ```

1. Retrieve and store the cluster's `ca.crt`

    ```bash
    export CA_PEM=$(kubectl get cm kube-root-ca.crt -o jsonpath="{['data']['ca\.crt']}") && echo "$CA_PEM"
    ```

1. Retrieve and store the `vault-tokenauth` token

    ```bash
    export SA_TOKEN=$(kubectl get secret -n vault-secrets-operator-system vault-tokenauth --output 'go-template={{ .data.token }}' | base64 --decode) && echo "$SA_TOKEN"
    ```

1. Store the cluster values as a secret in Vault

    ```bash
    vault kv put -mount="ltc-infrastructure" "clusters/${CLUSTER}" ca_pem="$CA_PEM" token_reviewer_jwt="$SA_TOKEN"
    ```

    > You could use the Vault UI to paste the values into the secret path and the Access -> Kubernetes Auth JWT token field.

Run `terraform apply` to configure the Kubernetes auth backend.
