terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
terraform {
  cloud {
    organization = "Jainil-Org"
    workspaces {
      name = "ForAssignment"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

locals {
  name  = "forum"
  owner = "jainil patel"
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default"
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC47EM8owmxDWzZjVtRreGH73gFSiDIRKaKsAxIjJjBcjqLVNVSJl0ToXpLyj3aleYwjEwZq/I5Xy9YF5Md3ZVvsUaAQZnT2iIhbSlgmAYTSI5fReLSn+WNw8jOUq5q9mNvNdDBpg2IRXgsWylYPyl+VtKGc397yfKIqPS1KFnXtq4khlD+7BInWNYNExEh2lc3kpTzPg1M/xkV8PV1SKNBZUoEkYIWGOFzH+EglCmWgAuvRG9L4N7kF57p3Idy6PYPdKR3MtAHUaSsPvJDC2D3tbKonLu5EvP730Oo9r9YHP5JcE8Y6+Hn4vJx+qQpZYxE9QN2UGXeR1TYUS67XCXr jainil@LAPTOP-3C70KJHN"
}

resource "aws_security_group" "allow_http_and_ssh" {
  name        = "allow_http_and_ssh"
  description = "This security groups allows http and ssh inbound traffic from all sources"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
  }
}

resource "aws_instance" "app_server" {
  ami                    = "ami-06b72b3b2a773be2b"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_and_ssh.id]

  key_name = aws_key_pair.mykeypair.key_name
  tags = {
    Name = "${local.name} ${local.owner}"
  }
  user_data = <<EOF
#!bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>HELLO WORLD FROM $(hostname -f)</h1>" > /var/www/html/index.html
systemctl restart httpd
  EOF
}

output "instance_ip_address" {
  value = aws_instance.app_server.public_ip
}
