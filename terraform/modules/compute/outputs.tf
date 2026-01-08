# ============================================================================
# OUTPUTS MODULE COMPUTE
# ============================================================================

output "alb_dns_name" {
  description = "DNS name du Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID du Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.magento.arn
}

output "asg_name" {
  description = "Nom de l'Auto Scaling Group"
  value       = aws_autoscaling_group.magento.name
}

output "asg_arn" {
  description = "ARN de l'Auto Scaling Group"
  value       = aws_autoscaling_group.magento.arn
}

output "launch_template_id" {
  description = "ID du Launch Template"
  value       = aws_launch_template.magento.id
}