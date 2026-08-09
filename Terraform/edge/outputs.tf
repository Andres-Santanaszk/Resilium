output "cloudfront_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}