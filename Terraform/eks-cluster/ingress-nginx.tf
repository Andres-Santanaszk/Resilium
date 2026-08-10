resource "helm_release" "external_nginx" {
  name = "external"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true
  version          = "4.15.1"

  values = [
    file("${path.module}/../../Kubernetes-manifests/values/nginx-ingress.yaml")
  ]

  set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
      value = aws_security_group.cloudfront_origin.id
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-manage-backend-security-group-rules"
      value = "true"
      type  = "string"
    }
  ]
  depends_on = [
    helm_release.aws_lbc
  ]
}