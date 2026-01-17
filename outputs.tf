# Root outputs

## OIDC - Per-client IDs for configuring downstream apps
output "idp_client_ids" {
  value = module.oidc_auth.idp_client_ids
}

## OIDC - Issuer + discovery endpoints for downstream apps
output "idp_issuer_urls" {
  value = module.oidc_auth.idp_issuer_urls
}

## AppRole role IDs for machine auth
output "approle_role_ids" {
  value = module.approle_auth.role_ids
}

## Kubernetes
output "kubernetes_auths" {
  value = module.kubernetes_auth.env_to_backend
}

output "kubernetes_hosts" {
  value = module.kubernetes_auth.cluster_hosts
}

## PostgreSQL
output "vault_db_connections" {
  value = module.postgresql.connections
}

output "vault_db_roles" {
  value = module.postgresql.roles
}
