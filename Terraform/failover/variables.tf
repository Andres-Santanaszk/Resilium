variable "vpn_key" {
  type        = string
  sensitive   = true
  description = "Tu AUTH KEY de Tailscale (Generada en el admin console)"
}

variable "aws_access_key" {
  description = "aa"
  type        = string
  sensitive   = true
}
variable "aws_secret_key" {
  description = "secret"
  type        = string
  sensitive   = true
}