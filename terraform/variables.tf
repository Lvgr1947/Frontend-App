variable "aws_region" {
  default = "ap-south-1"  # or your AWS region
}

variable "key_name" {
  default = "my-key"      # this must match the name in AWS Console
}

variable "public_key_path" {
  default = "C:/Users/rohith/.ssh/my-key.pub"
}
