resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us_east_1

  name  = "resilium-cloudfront"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit-by-ip"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = 500
        aggregate_key_type    = "IP"
        evaluation_window_sec = 60
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-by-ip"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "resilium-cloudfront-waf"
    sampled_requests_enabled   = true
  }
}