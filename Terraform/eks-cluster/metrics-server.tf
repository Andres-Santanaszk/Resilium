resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [
    file("${path.module}/../../Kubernetes-manifests/values/metrics-server.yaml")
  ]

  depends_on = [
    aws_eks_node_group.general
  ]
}

resource "helm_release" "prometheus-agent" {
   name             = "prometheus-agent-eks"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "88.1.4" # O una versión reciente compatible con tu clúster
  namespace        = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/../Kubernetes-manifests/values/prometheus-agent.yaml")
  ]

  depends_on = [
    helm_release.aws_lbc
  ]
}
