resource "aws_security_group" "tailscale_internal_sg" {
  name   = "${local.env}-tailscale-internal"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block] # Permite tráfico de todo tu clúster EKS
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tailscale_internal" {
  ami           = "ami-0fb110df4c5094d21" # Cambia al AMI de Ubuntu 22.04 de tu región principal
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_zone1.id # Vive segura en la subred privada

  vpc_security_group_ids = [aws_security_group.tailscale_internal_sg.id]
  source_dest_check      = false # OBLIGATORIO para que funcione como router

  tags = { Name = "${local.env}-vpn-router-internal" }

  user_data = <<-EOF
    #!/bin/bash
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up --authkey="${var.vpn_key}" --advertise-routes="${aws_vpc.main.cidr_block}"
    sudo iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
    sudo tailscale set --accept-routes
  EOF
}