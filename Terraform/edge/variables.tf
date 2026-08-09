variable "aws_region" {
  description = "AWS region where the application infrastructure runs"
  type        = string
  default     = "us-west-1"
}

variable "domain_name" {
  description = "Public domain served by CloudFront"
  type        = string
  default     = "andrzejkl.site"
}