resource "aws_iam_user" "resilium-member" {
  name = "alberto"
}


resource "aws_iam_policy" "resilium_devs" {
  name = "AmazonEKSDeveloperPolicy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "resilium_users" {
  user       = aws_iam_user.resilium-member.name
  policy_arn = aws_iam_policy.resilium_devs.arn
}

resource "aws_eks_access_entry" "developer" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_user.resilium-member.arn
  kubernetes_groups = ["my-reader"]
}
