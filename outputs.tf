# outputs.tf

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.lab_instance.public_ip
}

output "secure_bucket_name" {
  description = "Secure S3 bucket name"
  value       = aws_s3_bucket.secure_bucket.bucket
}

output "insecure_bucket_name" {
  description = "Insecure S3 bucket name"
  value       = aws_s3_bucket.insecure_bucket.bucket
}