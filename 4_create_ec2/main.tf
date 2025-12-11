# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.25.0"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

output "ami_info" {
  value = jsonencode(data.aws_ami.ami)
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
# 取得 default VPC（用來掛 Security Group）
data "aws_vpc" "default" {
  default = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# 開 HTTP
resource "aws_security_group" "web_sg" {
  # name        = "example-web-sg"
  description = "Allow HTTP to EC2"
  vpc_id      = data.aws_vpc.default.id

  # HTTP 流量通過
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 允許所有流量輸出
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "example-web-sg"
  }
}

# 開啟 ssh port
resource "aws_security_group" "ssh_sg" {
  # name        = "example-ssh-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "example-ssh-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "example" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.web_sg.id,
    aws_security_group.ssh_sg.id
  ]

  # 已先建立的 key pair
  # key_name = "test"

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "HelloWorld"
  }
}

output "ec2_info" {
  value = jsonencode(aws_instance.example)
}

# 測試 EC2 站點
output "endpoint" {
  value = "http://${aws_instance.example.public_ip}"
}
