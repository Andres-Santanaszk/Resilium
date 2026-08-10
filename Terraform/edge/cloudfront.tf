resource "aws_cloudfront_distribution" "main" {
  enabled = true

  aliases = [
    "andrzejkl.site"
  ]

  web_acl_id = aws_wafv2_web_acl.cloudfront.arn

  origin {
    domain_name = "origin.andrzejkl.site"
    origin_id   = "eks-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

 
  default_cache_behavior {
    target_origin_id       = "eks-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    compress = true
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "eks-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}