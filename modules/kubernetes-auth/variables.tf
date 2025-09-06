variable "apps"              { type = list(string) }
variable "clusters"          {
  type = map(object({
    host        = string
    current_env = string
  }))
}
variable "common_policies"   { type = list(string) }
variable "token_bound_cidrs" { type = list(string) }
variable "token_ttl_seconds" { type = number }
