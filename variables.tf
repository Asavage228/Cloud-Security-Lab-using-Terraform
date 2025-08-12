variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"  # You can change this to your preferred region
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"  # You can change this as needed
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0de716d6197524dd9"  # Change this to the AMI of your choice
}

variable "key_name" {
  description = "The name of your EC2 key pair for SSH access"
  type        = string
  default     = "my-key-pair"  # If you don't want to specify it every time
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names"
  default     = "mysecuritylab"  # Prefix for your S3 bucket
}

# You can also add other optional variables here if necessary
