output "envs" {
  description = "Distinct environments derived from clusters.current_env"
  value       = sort(distinct([for cname, c in var.clusters : c.current_env]))
}

output "env_to_backend" {
  description = "Map of environment -> Kubernetes auth backend path name"
  value       = local.env_to_backend
}

output "cluster_hosts" {
  description = "Map of cluster -> API server host"
  value       = { for k, v in var.clusters : k => v.host }
}
