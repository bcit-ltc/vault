locals {
  # envs used by the postgres module (e.g. ["stable", "latest"])
  envs = distinct([for _, c in var.clusters : lower(trimspace(c.current_env))])

  # Per-env PG connection info (host/port)
  pg_connections = {
    for _, c in var.clusters :
    lower(trimspace(c.current_env)) => {
      host = c.workload_connection
      port = var.pg_port
    }
  }

  # Per-env admin passwords derived from the clusters map
  admin_passwords = {
    for _, c in var.clusters :
    lower(trimspace(c.current_env)) => c.postgresql_admin_password
  }
}