terraform {
  backend "s3" {
    region       = "us-west-1"
    bucket       = "resilium-terraform-state"
    key          = "global/edge/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
