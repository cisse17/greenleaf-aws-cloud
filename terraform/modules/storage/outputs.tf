# OUTPUTS MODULE STORAGE

output "s3_bucket_name" {
  description = "Nom du bucket S3"
  value       = aws_s3_bucket.media.id
}

output "s3_bucket_arn" {
  description = "ARN du bucket S3"
  value       = aws_s3_bucket.media.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name du bucket S3"
  value       = aws_s3_bucket.media.bucket_domain_name
}

output "ec2_instance_profile_name" {
  description = "Nom de l'instance profile pour EC2"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_iam_role_arn" {
  description = "ARN du rôle IAM pour EC2"
  value       = aws_iam_role.ec2_s3_access.arn
}