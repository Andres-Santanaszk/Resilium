data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "${aws_eks_cluster.eks.name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/Z057192534VYRGFNJJOD1"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name   = "${aws_eks_cluster.eks.name}-external-dns"
  policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns.arn
}

resource "helm_release" "external_dns" {
  name = "external-dns"

  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  set = [
    {
      name  = "provider.name"
      value = "aws"
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "domainFilters[0]"
      value = "andrzejkl.site"
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.external_dns,
    aws_eks_pod_identity_association.external_dns
  ]
}