variable "token_bound_cidrs" {
  description = "CIDRs to bind service account tokens for Kubernetes auth roles"
  type        = list(string)
  default     = []
}