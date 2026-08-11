variable "aws_region" {
  type = string
}
/*
variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}

variable "key_name" {
  type = string
}

variable "default_az" {
  type = string
}


variable "instances" {
  type = map(object({
    instance_type     = string
    availability_zone = string
    key_name          = optional(string)
    subnet_id         = string
  }))
}
*/
locals {
  env         = "staging"
  region      = "us-west-1"
  zone1       = "us-west-1a"
  zone2       = "us-west-1c"
  eks_name    = "selora-eks"
  eks_version = "1.34"
  aws_region  = "us-west-1"
}
variable "aws_access_key" {
  description = "aa"
  type        = string
  sensitive   = true
}
variable "aws_secret_key" {
  description = "secret"
  type        = string
  sensitive   = true
}
variable "wazuh_password" {
  description = "claves para los agentes de wazuh"
  type        = string
  sensitive   = true
}
variable "vpn_key" {
  description = "clave para conectarse al VPN automaticamente"
  type        = string
  sensitive   = true
}