# Configure kubernetes auth

> <https://developer.hashicorp.com/validated-patterns/vault/vault-kubernetes-auth>

A service account is required to authenticate with the kubernetes auth backend. The `vault-tokenauth` service account is created by the flux bootstrap init process (see the `flux` repo `init/README.md`). These steps retrieve the credentials to authenticate using this auth backend and them in the `certs-tokens` folder.

## Requirements

- Vault CLI
- Kubernetes CLI and cluster access
- jq

## Setup

1. Login to Vault

    ```bash
    vault login -method=oidc username={yourUsername}
    ```

1. Set the cluster context

    ```bash
    export CLUSTER=cluster0X

    kubectl config use-context ${CLUSTER}   # make sure your context matches your `~/.kube/config`
    ```

1. Retrieve the `kubernetes_host` value.

    ```bash
    kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
    ```

1. Set this value in `clusters.yaml` (project root)

1. Retrieve and store the `vault-tokenauth` token

    ```bash
    export SA_TOKEN=$(kubectl get secret -n vault-secrets-operator-system vault-tokenauth --output 'go-template={{ .data.token }}' | base64 --decode) && echo "$SA_TOKEN"
    ```

1. Retrieve and store the cluster's `ca.crt`

    ```bash
    export CA_PEM=$(kubectl get secret -n vault-secrets-operator-system vault-tokenauth --output 'go-template={{ index .data "ca.crt" }}' | base64 --decode) && echo "$CA_PEM"
    ```

1. Store the cluster values as a secret in Vault

    ```bash
    vault kv put -mount="ltc-infrastructure" "clusters/${CLUSTER}" ca_pem="$CA_PEM" token_reviewer_jwt="$SA_TOKEN"
    ```

Now the backend is prepared. Run `terraform apply` to configure Vault.
