# PKI Engine

The PKI engine issues certificates that can be used to protect *internal* endpoints. Protecting internal endpoints usually involves:

- creating a *server* cert and key to protect the server daemon
- creating a *client* cert and key whenever a connection needs to be made

"*internal* certificates are issued through an intermediate certificate authority "SICA (secondary intermediate certificate authority)" using the "pki" role

Certificates can be requested by an auth method that has permission granted the policy "pki-issue-certs" (see [policies](../policies/))

- For Ansible playbooks, a simple Userpass auth method can request certificates (see below)
- For apps, an AppRole auth method is more appropriate (see [approle-commands.md](../approle/approle-commands.md))

A certificate's default lifetime is 1 day, but adding an explicit `ttl="Xd"` (where X is in days) allows certs up to 1 year

## Initialization
#
The engine was configured according to the following guides:

- [vault-pki-demo](https://github.com/kaparora/vault-pki-demo)
- [pki API documentation](https://www.vaultproject.io/api-docs/secret/pki)
- [pki-engine tutorial](https://learn.hashicorp.com/tutorials/vault/pki-engine)
- [create CA with offline root](https://learn.hashicorp.com/tutorials/vault/pki-engine-external-ca?in=vault/secrets-management)

## Notes
- `certstrap` commands are run on the Vault server
- Root CA passphrase is stored in Vault at infrastructure > `pki`

## 1. Create a Root CA
certstrap init \
--organization "British Columbia Institute of Technology" \
--organizational-unit "LTC" \
--country "CA" \
--province "BC" \
--locality "Burnaby" \
--common-name "BCIT LTC PKI Root CA" \
--path-length "2" \
--expires "10 years"

**Passphrase stored in Vault**


## 2. Apply the Terraform `pki` module to generate an Intermediate CA csr
#
terraform plan
terraform apply

**commands will fail until the CSR is retrieved and a new signed cert is added**


## 3. Retrieve the Intermediate CA csr and sign with the Root CA
#
terraform show -json | jq '.values."root_module"."child_modules"[].resources[].values.csr' -r | grep -v "null"
**copy the first one**

**On the Vault server**
1. add the csr to `csr/BCIT_LTC_PKI_PICA.csr`
1. certstrap sign \
--expires "2 years" \
--csr csr/BCIT_LTC_PKI_PICA.csr \
--cert out/BCIT_LTC_PKI_PICA.crt \
--intermediate \
--path-length "2" \
--CA "BCIT LTC PKI Root CA" \
"BCIT LTC PKI Primary Intermediate CA v2"
1. Copy the newly signed `out/BCIT_LTC_PKI_PICA.crt` and add it with the Root CA cert to `pki/BCIT_LTC_PKI_PICA.crt`

## 4. Re-run `terraform apply` to finish the module deployment
terraform plan
terraform apply

## 5. Issue certificates with a call to the leaf intermediate (SICA)

vault write -format=json pki/sica/v2/issue/spire-x509pop common_name=gate-03.ltc.bcit.ca | jq .data.certificate -r | openssl x509 -in /dev/stdin -text -noout
