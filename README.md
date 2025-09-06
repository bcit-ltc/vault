# HashiCorp Vault with Terraform

This project deploys HashiCorp Vault resources and stores the remote state in Azure Blob Storage.

## Prerequisites

- Terraform >= 1.0
- Azure subscription with permissions to create resources
- Azure CLI
- Vault CLI
- Kubernetes CLI (for `modules/kubernetes-auth`)

## Getting Started

1. Login to Vault (VPN required)

1. Run Terraform commands:

```bash
terraform apply -target=module.userpass-auth.vault_auth_backend.userpass -auto-approve
terraform plan
terraform apply
```
