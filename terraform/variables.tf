variable "region" {
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "ami" {
  description = "Amazon Linux 2023 AMI ID"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair Name"
}