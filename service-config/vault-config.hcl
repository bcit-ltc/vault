ui = true

disable_mlock = true

storage "raft" {
  path    = "/opt/vault"
  node_id = "raft_node_1"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/pki/tls/certs/star-ltc-bcit-ca-2022-bundle.crt"
  tls_key_file  = "/etc/pki/tls/private/star-ltc-bcit-ca-2022.key"
}

listener "tcp" {
  address     = "127.0.0.1:8202"
  tls_disable = "true"
}

api_addr      = "http://127.0.0.1:8200"
cluster_addr  = "https://127.0.0.1:8201"
log_format    = "json"

telemetry {
  disable_hostname = true
  enable_hostname_label = true
}

# Operating credentials stored in `/etc/vault.d/vault.env`; also see `ltc-infrastructure/vault/awskms`
seal "awskms" {
  region = "us-west-2"
  kms_key_id = "58f9d730-aba5-4de8-867f-d45ffb1ee443"
}
