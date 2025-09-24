# Derived values used across resources
locals {
  # Distinct environments from cluster defs
  envs = sort(distinct([for cname, c in var.clusters : c.current_env]))

  # Auth backends are named kubernetes-{env}
  env_to_backend = { for e in local.envs : e => "kubernetes-${e}" }

  # Map env -> cluster name and env -> API host
  env_to_cluster = { for cname, c in var.clusters : c.current_env => cname }
  env_to_host    = { for cname, c in var.clusters : c.current_env => c.host }

  # Build the full app list = standalones ∪ grouped children
  all_apps = sort(distinct(concat(
    var.apps,
    flatten([for _, children in var.apps_grouped : children])
  )))

  # Cartesian product of (all_apps × envs) for role/policy creation
  app_envs = {
    for combo in flatten([
      for app in local.all_apps : [
        for env, backend in local.env_to_backend : {
          key     = "${app}-${env}"
          app     = app
          env     = env
          backend = backend
        }
      ]
    ]) : combo.key => combo
  }
}

# Read cluster auth materials (one read per cluster)
# KV v2 + generic_secret:
# - Use the logical path WITHOUT "/data/" (provider rewrites internally).
# - e.g., secrets/clusters/cluster02
data "vault_generic_secret" "k8s_auth_materials" {
  for_each = var.clusters
  path     = "${var.k8s_auth_path_prefix}/${each.key}"
}

# Normalize KV-v2 shapes for fields we need
locals {
  ca_pem_by_cluster = {
    for cname, s in data.vault_generic_secret.k8s_auth_materials :
    cname => coalesce(
      try(s.data["data"]["ca_pem"], null),
      try(s.data["ca_pem"], null)
    )
  }

  token_by_cluster = {
    for cname, s in data.vault_generic_secret.k8s_auth_materials :
    cname => coalesce(
      try(s.data["data"]["token_reviewer_jwt"], null),
      try(s.data["token_reviewer_jwt"], null)
    )
  }
}

# Parent binding map (child app -> parent namespace)
locals {
  # Standalone apps: app -> app
  standalone_map = { for a in var.apps : a => a }

  # Grouped: (parent -> [children]) -> flatten to pairs, then to a map
  grouped_pairs = flatten([
    for parent, children in var.apps_grouped : [
      for child in children : {
        key   = child
        value = parent
      }
    ]
  ])

  grouped_map = { for p in local.grouped_pairs : p.key => p.value }

  # Merge, letting grouped override standalones if duplicated
  app_parent_map = merge(local.standalone_map, local.grouped_map)
}
