data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "cloudfront_origin" {
  name        = "${local.env}-${local.eks_name}-cloudfront-origin"
  description = "Allow HTTPS only from CloudFront origin-facing servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.env}-${local.eks_name}-cloudfront-origin"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront_https" {
  security_group_id = aws_security_group.cloudfront_origin.id

  ip_protocol    = "tcp"
  from_port      = 443
  to_port        = 443
  prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id
}

resource "aws_vpc_security_group_egress_rule" "cloudfront_origin_all" {
  security_group_id = aws_security_group.cloudfront_origin.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}