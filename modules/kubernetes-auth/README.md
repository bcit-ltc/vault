# Kubernetes Auth

Minimal module to configure Kubernetes auth method. Apps are granted access to a cluster's auth method for each environment.

```txt
qcon => creates role and policy for "read-apps-qcon-stable"
- configures auth for "stable" cluster (and follows the same pattern for other envs and clusters)
```

## Inputs

- `clusters` (map(object{ host, current_env })) — required
- `apps` (list(string)) — required
- `common_policies` (list(string)) — default `[]`
- `token_bound_cidrs` (list(string)) — default `[]`
- `token_ttl_seconds` (number) — default `14400`
- `k8s_auth_path_prefix` (string)
- `apps_grouped` (map(list(string))) - default `{}`

## Example call

```hcl
clusters = {
  cluster0X = {
    host        = "https://k8s-api-endpoint.local:6443"
    current_env = "latest"
  }
}

output "cluster_hosts" {
  description = "Map of cluster -> API server host"
  value       = { for k, v in var.clusters : k => v.host }
```
