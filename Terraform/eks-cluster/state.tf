terraform {
  backend "s3" {
    region       = ""
    bucket       = ""
    key          = "global/eks-cluster/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
