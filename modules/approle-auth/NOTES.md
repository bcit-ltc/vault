# AppRole auth method - Setup and Usage

> See <https://www.vaultproject.io/docs/auth/approle>

The AppRole auth method allows apps to login and retrieve secrets from Vault. The method uses a `role_id` and a `secret_id` to login and retrieve a token which is then used to retrieve secrets from Vault.

Because this auth method is designed to be used with automation, the TTL of the `secret_id` is very short. The period lifetime of the token *once authenticated*, however, is 30d, which should give apps enough time to periodically renew.

## AppRole Example 1: Read secrets from "/external"

Roles are created using the values in `approle-roles.yaml`. Every AppRole role has a `role_id` and a `secret_id` that can be used by automated systems to retrieve a token and read secrets.

1. Using your own credentials, confirm the `role_id`

    ```bash
    vault login -method=oidc username={yourUsername}

    export ROLE_ID="$(vault read -format=json auth/approle/role/read-external/role-id
    | jq -r '.data.role_id')" && echo $ROLE_ID
    ```

1. Generate a token that can use a role

    > The `approle-token-create` role creates a token that has permission to read an AppRole auth method's `secret_id`, nothing else!

    ```bash
    vault token create -role=approle-token-create
    ```

1. Get the role's `secret_id`

    ```bash
    export SECRET_ID="$(vault write -format=json -force auth/approle/role/read-external/secret-id | jq -r '.data.secret_id')" && echo $SECRET_ID
    ```

1. Use the `role_id` and `secret_id` to login. Authentication provides a token which can be used to retrieve secrets from `/external`.

    ```bash
    export VAULT_TOKEN="$(vault write -format=json auth/approle/login role_id=${ROLE_ID} secret_id=${SECRET_ID} | jq -r '.auth.client_token')" && echo $VAULT_TOKEN
    ```

1. Use the approle token to read a secret (in this example, at /web-apps/external/wordpress-ltc-on-point)

    ```bash
    vault kv get -mount="external" "wordpress/ltc-on-point" | jq -r '.data.data'
    ```

## AppRole Example 2: Retrieve SSL Certificates

This AppRole method demonstrates how to retrieve SSL certificates.

1. Login to Vault

    ```bash
    vault login -method=ldap username={yourUsername}
    ```

1. Create a token

    ```bash
    vault token create -role=approle-token-create
    ```

1. Retrieve the AppRole role RoleID

    ```bash
    export ROLE_ID="$(vault read -format=json auth/approle/role/read-ltc-infrastructure-ssl-certificates/role-id | jq -r '.data.role_id')" && echo $ROLE_ID
    ```

1. Retreive a SecretID

    ```bash
    export SECRET_ID="$(vault write -format=json -force auth/approle/role/read-ltc-infrastructure-ssl-certificates/secret-id | jq -r '.data.secret_id')" && echo $SECRET_ID
    ```

1. Obtain an AppRole auth method token

    ```bash
    export VAULT_TOKEN="$(vault write -format=json auth/approle/login role_id=${ROLE_ID} secret_id=${SECRET_ID} | jq -r '.auth.client_token')" && echo $VAULT_TOKEN
    ```

1. Retrieve SSL certificates

    ```bash
    vault kv get -mount="ltc-infrastructure" "ssl-certificates/star-ltc-bcit-ca"
    ```
