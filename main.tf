# Get apps/clusters and common config
locals {
  apps_config     = yamldecode(file("${path.module}/apps.yaml"))
  clusters_config = yamldecode(file("${path.module}/clusters.yaml"))
  idcfg           = yamldecode(file("${path.module}/modules/identities/identities.yaml"))

  # Environments are the distinct values of clusters[*].current_env
  envs = sort(distinct([for cname, c in local.clusters_config.clusters : c.current_env]))
}

# Mod 1: Automated machine-based authentication
module "approle-auth" { source = "./modules/approle-auth" }

# Mod 2: Identity and access management
module "identities" {
  source  = "./modules/identities"
  entities = local.idcfg.entities
  groups   = local.idcfg.groups
  aliases  = try(local.idcfg.aliases, { groups = [], entities = [] })
}

# Mod 3: Kubernetes mounts, backend config, and roles
module "kubernetes-auth" {
  source            = "./modules/kubernetes-auth"

  apps              = local.apps_config.apps
  clusters          = local.clusters_config.clusters
  common_policies   = try(local.clusters_config.common_policies, [])
  token_bound_cidrs = local.clusters_config.token_bound_cidrs
  token_ttl_seconds = local.clusters_config.token_ttl_seconds
}

# Mod 4: AzureAD auth
module "oidc-auth" {
  source = "./modules/oidc-auth"
}

# Mod 5: Policies for apps (per env)
module "policies" {
  source   = "./modules/policies"
  apps     = local.apps_config.apps
  envs     = local.envs
  kv_mount = local.apps_config.acl_policy_mount
}

# Mod 6:  KV secrets engines
module "secrets" { source = "./modules/secrets" }

# Mod 7:  Token management
module "tokens" {
  source = "./modules/tokens"
}

# Mod 8: Sops and transit engines
module "transit" { source = "./modules/transit" }

# Mod 9: Username and password authentication
module "userpass-auth" { source = "./modules/userpass-auth" }

# Vault and Azure backend state storage configuration
# - see https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
#
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
  backend "azurerm" {
    container_name = "tfstate"
    key = "vault-infrastructure.tfstate"
    storage_account_name = "tfstate21402"
    use_azuread_auth = true
    use_cli = true
  }
}
