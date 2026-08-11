# ==========================================
# PROVEEDOR SECUNDARIO (EL RESPALDO)
# ==========================================
provider "aws" {
  alias      = "backup"
  region     = "us-west-2" # Oregon
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Red pública mínima para el Proxy de Respaldo
resource "aws_vpc" "backup_vpc" {
  provider             = aws.backup
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "backup_igw" {
  provider = aws.backup
  vpc_id   = aws_vpc.backup_vpc.id
}

resource "aws_subnet" "backup_public" {
  provider                = aws.backup
  vpc_id                  = aws_vpc.backup_vpc.id
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = true # OBLIGATORIO: Los clientes de internet deben poder llegar aquí
}

resource "aws_route_table" "backup_rt" {
  provider = aws.backup
  vpc_id   = aws_vpc.backup_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.backup_igw.id
  }
}

resource "aws_route_table_association" "backup_rta" {
  provider       = aws.backup
  subnet_id      = aws_subnet.backup_public.id
  route_table_id = aws_route_table.backup_rt.id
}

resource "aws_security_group" "backup_proxy_sg" {
  provider = aws.backup
  name     = "proxy-failover-sg"
  vpc_id   = aws_vpc.backup_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Puertos web para recibir a los clientes
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# EL PROXY SALVAVIDAS (EC2 Región B)
# ==========================================
resource "aws_instance" "public_proxy_failover" {
  provider               = aws.backup
  ami                    = "ami-02167eae61967e403" # Ubuntu 22.04 LTS en us-west-2
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.backup_public.id
  vpc_security_group_ids = [aws_security_group.backup_proxy_sg.id]
  source_dest_check      = false # OBLIGATORIO para que funcione como router


  tags = { Name = "failover-proxy-public" }

  # Este script instala Tailscale Y un Proxy inverso (Nginx)
  user_data = <<-EOF
    #!/bin/bash
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up --authkey="${var.vpn_key}"
    sudo iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
    sudo tailscale set --accept-routes

  }
  EOF
}