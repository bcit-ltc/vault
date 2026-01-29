ui = true

disable_mlock = true

storage "raft" {
  path    = "/opt/vault"
  node_id = "raft_node_1"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/....crt"
  tls_key_file  = "/opt/vault/tls/....key"
  tls_disable_client_certs = "true"
}

listener "tcp" {
  address     = "127.0.0.1:8202"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"

log_format = "json"
log_level = "error"

plugin_directory = "/opt/vault/plugins"

telemetry {
  disable_hostname = true
  enable_hostname_label = true
}

seal "awskms" {
  region = "us-west-2"
  kms_key_id = "58f9d730-aba5-4de8-867f-d45ffb1ee443"
  # access_key = "..."
  # secret_key = "..."
}

#seal "azurekeyvault" {
#  tenant_id      = "46646709-b63e-4747-be42-516edeaf1e14"
#  client_id      = "03dc33fc-16d9-4b77-8152-3ec568f8af6e"
#  client_secret  = "..."
#  vault_name     = "hc-vault"
#  key_name       = "vault_key"
#}
