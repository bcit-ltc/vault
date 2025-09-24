# Auth & subscription come from Azure CLI
#
#   az login
#   az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
#
# Set environment variables:
#
#   export TF_VAR_tenant_id=$(az account show --query tenantId -o tsv)
#   export TF_VAR_subscription_id=$(az account show --query id -o tsv)
#
#     (or use a `terraform.tfvars` file)
#
provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}
