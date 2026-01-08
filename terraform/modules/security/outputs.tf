# ============================================================================
# OUTPUTS MODULE SECURITY
# ============================================================================

output "alb_security_group_id" {
  description = "ID du security group ALB"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID du security group EC2"
  value       = aws_security_group.ec2.id
}

output "db_security_group_id" {
  description = "ID du security group RDS"
  value       = aws_security_group.rds.id
}

output "cache_security_group_id" {
  description = "ID du security group ElastiCache"
  value       = aws_security_group.cache.id
}