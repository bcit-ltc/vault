variable "organization" {
  description = "Organization name for PKI certificates"
  type        = string
}

variable "short_org" {
  description = "Short organization name for PKI certificates"
  type        = string
}

variable "country" {
  description = "Country for PKI certificates"
  type        = string
}

variable "province" {
  description = "Province for PKI certificates"
  type        = string
}

variable "locality" {
  description = "Locality for PKI certificates"
  type        = string
}

variable "ou" {
  description = "Organizational Unit for PKI certificates"
  type        = string
}

variable "primary_ca_cert_path" {
  description = "Path to the signed Primary Intermediate CA certificate file"
  type        = string
}

variable "allowed_domains" {
  description = "List of allowed domains for standard PKI roles"
  type        = list(string)
}
