# Admin policies
module "admin_system" {
  source = "./modules/admin-policies"
}

# KV secrets engines
module "secrets" {
  source = "./modules/secrets"
}

# Identities (entities + groups + aliases from YAML)
module "identities" {
  source               = "./modules/identities"
  identities_yaml_path = "./identities.yaml"
  oidc_auth_accessor   = module.oidc_auth.oidc_auth_accessor
}

# OIDC login + Vault-as-IdP with multiple downstream clients

# Retrieve upstream IdP's OIDC auth credentials from Vault
data "vault_generic_secret" "oidc_credentials_path" {
  path = var.oidc_credentials_path
}
module "oidc_auth" {
  source                = "./modules/oidc-auth"
  tenant_id             = var.tenant_id
  oidc_auth_path        = "oidc"
  oidc_client_id        = data.vault_generic_secret.oidc_credentials_path.data["client_id"]
  oidc_client_secret    = data.vault_generic_secret.oidc_credentials_path.data["client_secret"]
  allowed_redirect_uris = var.allowed_redirect_uris
  provider_name         = "vault-provider"
  issuer_host           = var.issuer_host
  clients               = var.oidc_clients
}

# Kubernetes mounts, backend config, and roles
module "kubernetes_auth" {
  source               = "./modules/kubernetes-auth"
  clusters             = var.clusters
  apps                 = var.apps
  common_policies      = var.common_policies
  token_bound_cidrs    = var.token_bound_cidrs
  token_ttl_seconds    = var.token_ttl_seconds
  k8s_auth_path_prefix = var.k8s_auth_path_prefix
  apps_grouped         = var.apps_grouped
  private_legacy_apps  = var.private_legacy_apps
}

# Automated machine-based authentication
module "approle_auth" {
  source                = "./modules/approle-auth"
  token_ttl_seconds     = 3600
  token_max_ttl_seconds = 86400
  token_bound_cidrs     = var.token_bound_cidrs

  # Override/add roles here, policies per role
  approle_roles = {
    read-external = { 
      token_policies = ["default","read-external"]
    }
    read-ltc-infrastructure-ssl-certificates = { 
      token_policies = ["default","read-ltc-infrastructure-ssl-certificates"]
    }
    # ci-role = {
    #   token_policies        = ["default","read-apps","write-external"]
    #   token_ttl_seconds     = 900
    #   token_bound_cidrs     = ["192.168.0.0/24"]
    #   token_no_default_policy = true
    # }
  }

  # Roles for which SecretID creation is permitted
  approle_secretid_roles = ["read-ltc-infrastructure-ssl-certificates"]
}

# Database management
module "postgresql" {
  source = "./modules/databases/postgresql"

  # Environments should match cluster environments (unique, lowercased)
  envs = distinct([for _, c in var.clusters : lower(trimspace(c.current_env))])
  # envs = ["stable", "latest"]

  # Mounts will be: postgresql-<env>
  db_mount_prefix      = "postgresql"

  # Apps -> roles created per env
  postgresql_databases = var.postgresql_databases

  # Derive per-env connection from clusters
  pg_connections = {
    for _, c in var.clusters :
    lower(trimspace(c.current_env)) => {
      host = c.workload_connection
      port = var.pg_port
    }
  }

  # DB admin creds used for the connection (same across envs)
  admin_username = var.postgresql_admin_username
  admin_password = var.postgresql_admin_password
}

# Token management
module "tokens" {
  source             = "./modules/tokens"
  token_bound_cidrs    = var.token_bound_cidrs
}

# SOPS and transit engines
module "transit" {
  source                = "./modules/transit"
}

# Username and password authentication
module "userpass_auth" {
  source                = "./modules/userpass-auth"
  userpass_accessor     = module.userpass_auth.userpass_accessor
}

# Vault and Azure backend state storage configuration
# - see https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.18.0"
    }
  }

  backend "azurerm" {
    container_name       = "tfstate"
    storage_account_name = "tfstatez55vivoh"
    use_azuread_auth     = true
    use_cli              = true

    # blob key = vault
  }
}
