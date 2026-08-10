resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us_east_1

  name  = "resilium-cloudfront"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
  name     = "aws-ip-reputation"
  priority = 20

  override_action {
    count {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesAmazonIpReputationList"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-ip-reputation"
    sampled_requests_enabled   = true
  }
}

rule {
  name     = "aws-common-rules"
  priority = 30

  override_action {
    count {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-common-rules"
    sampled_requests_enabled   = true
  }
}

rule {
  name     = "aws-known-bad-inputs"
  priority = 40

  override_action {
    count {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-known-bad-inputs"
    sampled_requests_enabled   = true
  }
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