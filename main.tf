provider "aws" {
  region = var.aws_region
}

# VPC Setup
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "CloudSecurityLabVPC"
  }
}

# Subnet Setup
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

# Security Group Setup
resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_vpc.id
  name   = "lab-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can limit this to your IP for better security
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# EC2 Instance Setup
resource "aws_instance" "lab_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name      = var.key_name

  tags = {
    Name = "CloudSecurityLabEC2"
  }
}

# Secure S3 Bucket Setup (with unique names)
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "cloudsecuritylab-secure-${random_id.bucket_suffix.hex}"
  acl    = "private"
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Insecure S3 Bucket Setup (with unique names)
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "cloudsecuritylab-insecure-${random_id.bucket_suffix.hex}"
 }

# Random ID for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "CloudSecurityLab-LogGroup"
  retention_in_days = 7  # Optional: Set retention to 7 days or customize
}

# CloudWatch Alarm for EC2 instance CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors high CPU usage for EC2 instance"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.lab_instance.id
  }

  alarm_actions = [
    # Provide your SNS Topic ARN here to get notifications
    # "arn:aws:sns:us-east-1:123456789012:YourSNSTopic"
  ]
}

# S3 Bucket to store CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_log_bucket" {
  bucket = "cloudsecuritylab-cloudtrail-logs-${random_id.bucket_suffix.hex}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# IAM Role for CloudTrail to publish to CloudWatch Logs
resource "aws_iam_role" "cloudwatch_role" {
  name = "CloudTrail-CloudWatch-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for CloudTrail to log into CloudWat


