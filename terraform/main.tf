# ----------------------------
# Create VPC
# ----------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "FinalProject-VPC"
  }
}
# ----------------------------
# Create Public Subnet
# ----------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "FinalProject-PublicSubnet"
  }
}
# ----------------------------
# Internet Gateway
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "FinalProject-IGW"
  }
}
# ----------------------------
# Public Route Table
# ----------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "FinalProject-PublicRouteTable"
  }
}
# ----------------------------
# Route Table Association
# ----------------------------
resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public.id

  route_table_id = aws_route_table.public_rt.id

}
# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "web_sg" {
  name        = "FinalProject-WebSG"
  description = "Allow SSH, HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FinalProject-WebSG"
  }
}
# ----------------------------
# IAM Role
# ----------------------------
resource "aws_iam_role" "ec2_role" {
  name = "FinalProject-EC2-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
# ----------------------------
# Attach CloudWatch Policy
# ----------------------------
resource "aws_iam_role_policy_attachment" "cloudwatch" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}
# ----------------------------
# IAM Instance Profile
# ----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {

  name = "FinalProject-InstanceProfile"

  role = aws_iam_role.ec2_role.name

}
# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "web_server" {

  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true

  tags = {
    Name = "FinalProject-EC2"
  }
}