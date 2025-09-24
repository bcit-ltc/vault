locals {
  ttl_4h  = 14400      # 4 hours
  ttl_30d = 2592000    # 30 days

  # Common CIDR guardrail
  bound_cidrs = [
  "10.12.0.0/16",
  "10.42.0.0/16",
  "10.67.0.0/16",
  "142.232.0.0/16",
  "192.68.68.0/24"
  ]
}
