terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.36.0"
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
}

resource "aws_instance" "app_server" {
  ami           = "ami-06b72b3b2a773be2b"
  instance_type = "t2.micro"
  user_data     = <<EOF
#!bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>HELLO WORLD FROM $(hostname -f)</h1>" > /var/www/html/index.html
systemctl restart httpd
  EOF
  tags = {
    Name = "${local.name} ${local.owner}"
  }
}

output "instance_ip_address" {
  value = aws_instance.app_server.public_ip
}
